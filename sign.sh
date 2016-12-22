#!bin/bash
if [[ ! $1 || "${1##*.}" != "apk" ]]; then
	echo "找不到 apk文件"
	echo "用法：sh sign.sh <apk-file> [output-directory]"
	exit 0
fi


scriptDir=$(cd `dirname $0`; pwd);
if [[ ! $2 ]]; then
	outdir="$scriptDir/output"
	if [ ! -d "$outdir" ]; then  
		mkdir $outdir
	fi
else
	outdir=$2
fi

if [[ ! -f "$scriptDir/zipalign" ]]; then 
	echo "缺少 zipalign 文件，请将 android-sdk/build-tools/version/zipalign 文件复制到脚本目录中"
	exit 0
fi


signPropertiesFileName="sign.properties"
signPropertiesFilePath="$scriptDir/$signPropertiesFileName"

echo $signPropertiesFilePath

if [[ ! -f $signPropertiesFilePath ]]; then 
	echo "创建 $signPropertiesFileName"
	touch $signPropertiesFilePath
	echo "#加固后签名配置" >> $signPropertiesFilePath
fi

getOrSetProperty(){
	local value=`cat $signPropertiesFilePath | grep "$1" | cut -d'=' -f2`

	while [[ ! $value ]]; do
		echo "$2"
		read -e value
		if [[ $value ]]; then
			echo "\n$1=$value" >> $signPropertiesFilePath
		fi
	done
	currentProperty="$value"
}

getOrSetProperty "keystore" "请输入 keystore 路径"
keystore=$currentProperty

getOrSetProperty "storepass" "请输入 storepass 密码"
storepass=$currentProperty

getOrSetProperty "keypass" "请输入 keypass 密码"
keypass=$currentProperty

getOrSetProperty "alias" "请输入 alias"
aliasValue=$currentProperty

# echo  "keystore = $keystore"
# echo  "storepass = $storepass"
# echo  "keypass = $keypass"
# echo  "alias = $aliasValue"

inputApk=$1
inputFileName=$(basename $inputApk .apk)
signApk="$outdir/$inputFileName-sign.apk"
signZipalignApk="$outdir/$inputFileName-sign-zipalign.apk" 


{  # try
rm -rf $signZipalignApk
rm -rf $signApk
jarsigner -verbose -digestalg SHA1 -sigalg MD5withRSA -keystore $keystore -storepass $storepass -keypass $keypass -signedjar $signApk $inputApk $aliasValue 
$scriptDir/zipalign -v 4 $signApk $signZipalignApk

} || { # catch
	rm -rf "$signApk"
	rm -rf "$signZipalignApk"
	echo "出错了…"
}
