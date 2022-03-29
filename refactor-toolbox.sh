#!/bin/bash

read -rp "Please type the version number to upgrade to: " newver
echo "You are attempting to upgrade to version: ${newver} "

get_release() {
read -rp "Please specify the release type (int) for internal release (gen) for general release: " release

case "${release}" in
  "int" | "INT" )
    container="refactor-test"
    fopcontainer="fop_test"
    run_update;;
  "gen" | "GEN" )
    container="refactor-prod"
    fopcontainer="fop_prod"
    run_update;;
  "all" | "ALL" )
    container="refactor-test"
    fopcontainer="fop_test"
    run_update
    container="refactor-prod"
    fopcontainer="fop_prod"
    run_update;;
  * )
    get_release;;
esac
}

#Commented out unless new flatworm is needed.  Will add code to prompt user if new flatworm is available.
#mkdir -pv "/medata/version_flatworm/${newver}"
#cp -v "/medata/updates/${newver}/TOOLBOX/flatworm/"* "/medata/version_flatworm/${newver}"

run_update () {
source="/medata/updates/${newver}/TOOLBOX/${container}"
target="/opt/${container}"
rpctarget=/opt/toolbox-rpc-new/java_lib/
mkdir -pv "${source}"
chown -R root:root "${source}"
chmod -R 775 "${source}"

sed -i 's/opt\/jdk1\.6\.0_16/usr\/java\/jdk1\.5\.0_22/g' "${source}/bin/*.sh"

"${target}/bin/setenv.sh"
"${target}/bin/shutdown.sh"
sleep 5

echo "Updating FOP containers"
cp -rv "/medata/updates/${newver}/CORE/SXML/"* "/opt/toolbox-rpc-new/${fopcontainer}/"

echo "Updating FOP libs"
cp -rv "/medata/updates/${newver}/CORE/lib_${container}/"* "${rpctarget}${container}/"

echo "Updating Tomcat binaries and libs"
#cp -rv "${source}/bin/"* "${target}/bin"
#cp -rv "${source}/common/"* "${target}/common"

# Shared Libs
cp -rv "${source}/shared/"* "${target}/shared"

echo "Updating Medata Toolbox base.war"
cp -v "${source}/webapps/base.war" "${target}/webapps/base.war"

echo "Running client specific Toolbox updates."
for client in $(awk '{print $1}' "${source}/clients"); do
echo  "Updating webapps folder for: ${client}"
  cp -rv "${source}/webapps/${client}" "${target}/webapps/"
done

"${target}/bin/setenv.sh"
"${target}/bin/startup.sh"
}

get_release

