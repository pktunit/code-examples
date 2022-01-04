#/bin/sh

read -p "Please type the version number to upgrade to: " NEWVER
echo "You are attempting to upgrade to version: ${NEWVER} "

get_release() {
read -p "Please specify the release type (int) for internal release (gen) for general release: " RELEASE

case $RELEASE in
  "int" | "INT" )
    CONTAINER="refactor-test"
    FOPCONTAINER="fop_test"
    run_update;;
  "gen" | "GEN" )
    CONTAINER="refactor-prod"
    FOPCONTAINER="fop_prod"
    run_update;;
  "all" | "ALL" )
    CONTAINER="refactor-test"
    FOPCONTAINER="fop_test"
    run_update
    CONTAINER="refactor-prod"
    FOPCONTAINER="fop_prod"
    run_update;;
  * )
    get_release;;
esac
}

#Commented out unless new flatworm is needed.  Will add code to prompt user if new flatworm is available.
#mkdir -pv /medata/version_flatworm/${NEWVER}
#cp -v /medata/updates/${NEWVER}/TOOLBOX/flatworm/* /medata/version_flatworm/${NEWVER}

run_update () {
SOURCE=/medata/updates/${NEWVER}/TOOLBOX/${CONTAINER}
TARGET=/opt/${CONTAINER}
RPCTARGET=/opt/toolbox-rpc-new/java_lib/
mkdir -pv ${SOURCE}
chown -R root:root ${SOURCE}
chmod -R 775 ${SOURCE}

sed -i 's/opt\/jdk1\.6\.0_16/usr\/java\/jdk1\.5\.0_22/g' ${SOURCE}/bin/*.sh

source ${TARGET}/bin/setenv.sh
${TARGET}/bin/shutdown.sh
sleep 5

echo "Updating FOP containers"
cp -rv /medata/updates/${NEWVER}/CORE/SXML/* /opt/toolbox-rpc-new/${FOPCONTAINER}/

echo "Updating FOP libs"
cp -rv /medata/updates/${NEWVER}/CORE/lib_${CONTAINER}/* ${RPCTARGET}${CONTAINER}/

echo "Updating Tomcat binaries and libs"
#cp -rv ${SOURCE}/bin/* ${TARGET}/bin
#cp -rv ${SOURCE}/common/* ${TARGET}/common

# Shared Libs
cp -rv ${SOURCE}/shared/* ${TARGET}/shared

echo "Updating Medata Toolbox base.war"
cp -v ${SOURCE}/webapps/base.war ${TARGET}/webapps/base.war

echo "Running client specific Toolbox updates."
for CLIENT in $(awk '{print $1}' ${SOURCE}/clients); do
echo  "Updating webapps folder for: ${CLIENT}"
  cp -rv ${SOURCE}/webapps/${CLIENT} ${TARGET}/webapps/
done

source ${TARGET}/bin/setenv.sh
${TARGET}/bin/startup.sh
}

get_release

