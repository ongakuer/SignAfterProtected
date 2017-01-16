#!bin/bash
if [[ ! $1 || "${1##*.}" != "apk" ]]; then
	echo "找不到 apk 文件"
	echo "用法：sh sign.sh <apk-file> [output-directory]"
	exit 0
fi


script_dir=$(cd `dirname $0`; pwd);
if [[ ! $2 ]]; then
	outdir="$script_dir/output"
	if [ ! -d "$outdir" ]; then  
		mkdir $outdir
	fi
else
	outdir=$2
fi

properties_path="$script_dir/sign.properties"

if [[ ! -f $properties_path ]]; then 
	echo "创建 $properties_path"
	touch $properties_path
	echo "#加固后签名配置" >> $properties_path
fi

get_property(){
	local value=`cat $properties_path | grep "$1" | cut -d'=' -f2`

	while [[ ! $value ]]; do
		echo "$2"
		read -e value
		if [[ $value ]]; then
			echo "\n$1=$value" >> $properties_path
		fi
	done
	current_property="$value"
}

get_property "android-sdk" "请输入 Android SDK 路径"
sdk_path=$current_property

get_property "keystore" "请输入 keystore 路径"
keystore=$current_property

get_property "storepass" "请输入 storepass 密码"
storepass=$current_property

get_property "keypass" "请输入 keypass 密码"
keypass=$current_property

get_property "alias" "请输入 alias"
aliasValue=$current_property

build_tools_path=$(find $sdk_path/"build-tools" -depth 1 -type d -print | tail -1)


# 检查 zipalign 和 apksigner
if [[ ! -f "$build_tools_path/zipalign" ]]; then 
	echo "找不到 zipalign 文件"
	exit 0
fi

if [[ ! -f "$build_tools_path/apksigner" ]]; then 
	echo "找不到 apksigner 文件"
	exit 0
fi

input_apk=$1
input_file_name=$(basename $input_apk .apk)
zipalign_apk="$outdir/$input_file_name-zipalign.apk" 
signed_apk="$outdir/$input_file_name-signed.apk"


{  # try
	rm -rf $zipalign_apk
	rm -rf $signed_apk
	$build_tools_path/zipalign -v 4 $input_apk $zipalign_apk
	$build_tools_path/apksigner sign --ks $keystore --ks-key-alias $aliasValue --ks-pass pass:$storepass --key-pass pass:$keypass --out $signed_apk $zipalign_apk
	rm -rf $zipalign_apk
	echo "签名完成 $signed_apk"
} || { # catch
	rm -rf "$signApk"
	rm -rf "$signZipalignApk"
	echo "出错了…"
}

# V1
# {  # try
# rm -rf $signZipalignApk
# rm -rf $signApk
# jarsigner -verbose -digestalg SHA1 -sigalg MD5withRSA -keystore $keystore -storepass $storepass -keypass $keypass -signedjar $signApk $inputApk $aliasValue 
# $script_dir/zipalign -v 4 $signApk $signZipalignApk

# } || { # catch
# 	rm -rf "$signApk"
# 	rm -rf "$signZipalignApk"
# 	echo "出错了…"
# }
