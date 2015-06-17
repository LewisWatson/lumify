export LUMIFY_HOME=${HOME}/git/lumify
export LOGDIR=/var/tmp/lumify/logs

if [[ ! -d ${LOGDIR} ]];then
    mkdir -p ${LOGDIR}
fi

printHelp() {
    echo "build.sh <option(s)>"
    echo ""
    echo "options include" 
    echo -e "\t-h\tprint this help info"
    echo -e "\t-t\tskip tests"
    echo -e "\t-i\tskip integration tests"
    echo -e "\t-m\tincrease memory"
    echo -e "\t-p\tincrease permgen"
    echo -e "\t-d\tdebug"
    echo ""
    return 0
}

MAVEN_GOALS="clean package assembly:assembly install"

while getopts ":htimpd" opt; do
    case $opt in
        t)
            MAVEN_ARGS="${MAVEN_ARGS} -DskipTests=true"
            ;;
        i)
            MAVEN_ARGS="${MAVEN_ARGS} -DskipITs"
            ;;
        m)
            MAVEN_OPTS="${MAVEN_OPTS} -Xms1024m -Xmx2048m"
            ;;
        p)
            MAVEN_OPTS="${MAVEN_OPTS} -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError"
            ;;
        d)
            MAVEN_ARGS="${MAVEN_ARGS} -X"
            ;;
        h)
            printHelp
            exit 0
            ;;
    esac
done

#echo "MAVEN_OPTS = ${MAVEN_OPTS}"
#echo "MAVEN_ARGS = ${MAVEN_ARGS}"
#echo "MAVEN_GOALS = ${MAVEN_GOALS}"

#mvn ${MAVEN_ARGS} ${MAVEN_GOALS}

mvn -X -P "grunt unix",web-war,web-war-with-gpw,web-war-with-ui-plugins clean package -DskipTests

