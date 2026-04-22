################################################################################
#
# python-html2text
#
################################################################################

PYTHON_HTML2TEXT_VERSION = 2025.4.15
PYTHON_HTML2TEXT_SOURCE = html2text-$(PYTHON_HTML2TEXT_VERSION).tar.gz
PYTHON_HTML2TEXT_SITE = $(call github,Alir3z4,html2text,$(PYTHON_HTML2TEXT_VERSION))
PYTHON_HTML2TEXT_LICENSE = GPL-3.0+
PYTHON_HTML2TEXT_LICENSE_FILES = COPYING
HOST_PYTHON_HTML2TEXT_SETUP_TYPE = setuptools
HOST_PYTHON_HTML2TEXT_DEPENDENCIES = host-python-setuptools-scm
HOST_PYTHON_HTML2TEXT_ENV = SETUPTOOLS_SCM_PRETEND_VERSION_FOR_HTML2TEXT=$(PYTHON_HTML2TEXT_VERSION)

$(eval $(host-python-package))
