ifndef STAGE4_MK
STAGE4_MK=stage4.mk

include init.mk

install/stage4: install/stage3 install/stage4-config install/stage4-workarounds
	# -- Recompile entire system
	${EMERGE} -ve -j system
	# -- cleaning up some workarounds
	CLEAN_DELAY=0 ${EMERGE} -C linux-headers
	# -- startprefix
	cd ${EPREFIX}/usr/portage/scripts && ./bootstrap-prefix.sh ${EPREFIX} startscript
	sed -i ${EPREFIX}/startprefix -e 's/^EPREFIX=/export EPREFIX=/g'
	# -- purge news
	eselect news purge
	touch $@

install/stage4-config: install/stage3 files/make.conf
	# -- Update make.conf
	cp -vf files/make.conf ${EPREFIX}/etc/
	echo "MAKEOPTS=\"${MAKEOPTS}\"" >> ${EPREFIX}/etc/make.conf
	# -- python: update USE and mask >python-2.7.1-r1 to avoid this bug:
	# http://bugs.python.org/issue9762
	echo 'dev-lang/python sqlite wide-unicode berkdb' > ${EPREFIX}/etc/portage/package.use/python
	#echo '>dev-lang/python-2.7.1-r1' > ${EPREFIX}/etc/portage/package.mask/python-2.7.1-r1+
	touch $@

install/stage4-workarounds: install/stage3 install/stage4-config
	# -- python: remove stage2 workaround
	rm -f ${EPREFIX}/etc/portage/env/dev-lang/python
	${EMERGE} -j dev-lang/python
	# -- net-tools: workaround
	${EMERGE} --oneshot --nodeps linux-headers
	touch $@

endif
