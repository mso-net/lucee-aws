FROM ortussolutions/commandbox:latest

MAINTAINER Simon Hooker <simon@mso.net>

COPY ./ ${BUILD_DIR}/
WORKDIR ${BUILD_DIR}
RUN box install

CMD cd $BUILD_DIR/tests && \
	box $BUILD_DIR/tests/runtests.cfm && \
	exitcode=$(<.exitcode) && \
	exit $exitcode
	