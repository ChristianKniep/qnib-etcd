PKG_NAME="qnib-etcd"
echo "PKG_NAME=${PKG_NAME}"
set -x
PKG_VERSION=$(git describe --match "[0-9]*" --abbrev=0 --tags)
TODAY="$(date +'%Y%m%d')"
ITER="1"
REPO_PATH=${REPO_PATH-./}
OLD_ITER=$(find ${REPO_PATH} -name "${PKG_NAME}-${PKG_VERSION}*"|sort|grep ${TODAY}|awk -F"${TODAY}." '{print $2}'|awk -F\. '{print $1}'|tail -n1)
echo "OLD_ITER=${OLD_ITER}"
if [ "X${OLD_ITER}" != "X" ];then
   ITER=$(echo "${OLD_ITER}+1"|bc)
fi
ARCH="x86_64"
FILE="${PKG_NAME}-${PKG_VERSION}-${TODAY}.${ITER}.${ARCH}.rpm"
echo "FILE=${FILE}"
FILE_PATH="${REPO_PATH}/${ARCH}/${FILE}"
mkdir -p "${REPO_PATH}/${ARCH}"
echo "FILE_PATH=${FILE_PATH}"
env fpm -s dir -t rpm -a ${ARCH} -p ${FILE_PATH} -n ${PKG_NAME} -v ${PKG_VERSION} --iteration ${TODAY}.${ITER} \
    -m 'Christian Kniep <christian@qnib.org>' \
    --description 'A highly-available key value store for shared configuration and service discovery.' \
    --provides etcd \
    -C packaged/ usr var
ec=$(echo $?)
echo "FPM EC: ${ec}"
if [ "X${ec}" != "X0" ];then
    exit ${ec}
fi
createrepo ${REPO_PATH}
