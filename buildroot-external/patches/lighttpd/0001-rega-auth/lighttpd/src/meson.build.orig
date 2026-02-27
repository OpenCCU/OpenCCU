compiler = meson.get_compiler('c')
sbindir = join_paths(get_option('prefix'), get_option('sbindir'))
moduledir = join_paths(get_option('prefix'), get_option('moduledir'))

include_base_paths = [
	'/usr/include',
	'/usr/local/include',
#	'/opt/local/include',
]

defs = [
	'-D_TIME_BITS=64',
	'-D_FILE_OFFSET_BITS=64',
	'-D_LARGEFILE_SOURCE',
	'-D_LARGE_FILES',
	'-D_DEFAULT_SOURCE',
	'-D_GNU_SOURCE',
]

socket_libs = []
if target_machine.system() == 'windows'
	socket_libs = [ compiler.find_library('ws2_32') ]
	defs += [
		'-DNVALGRIND',
	]
endif
if target_machine.system() == 'sunos'
	socket_libs = [ compiler.find_library('socket')
	              , compiler.find_library('nsl')
	              ]
elif target_machine.system() == 'haiku'
	socket_libs = [ compiler.find_library('network') ]
endif


conf_data = configuration_data()

headers = [
  'sys/inotify.h',
  'sys/loadavg.h',
  'sys/poll.h',
  'sys/prctl.h',
  'sys/procctl.h',
  'sys/sendfile.h',
  'sys/un.h',
  'sys/wait.h',
  'sys/time.h',
  'unistd.h',
  'dlfcn.h',
  'getopt.h',
  'inttypes.h',
  'poll.h',
  'pwd.h',
  'stdint.h',
  'stdlib.h',
  'strings.h',
  'syslog.h',
  'crypt.h',
  'malloc.h',
  'signal.h',
  'sys/epoll.h',
  'sys/event.h',
  'sys/mman.h',
  'sys/random.h',
  'linux/random.h',
  'sys/resource.h',
  'sys/uio.h',
]

foreach h : headers
  conf_data.set('HAVE_@0@'.format(h.underscorify().to_upper()), compiler.has_header(h))
endforeach

# will be needed for auth
libcrypt = []
if conf_data.get('HAVE_CRYPT_H')
	# check if we need libcrypt for crypt_r / crypt

	# crypt_r in default libs?
	if compiler.has_function('crypt_r', args: defs, prefix: '#include <crypt.h>')
		conf_data.set('HAVE_CRYPT_R', 1)
	# crypt_r in -lcrypt ?
	elif compiler.has_function('crypt_r', args: defs + ['-lcrypt'], prefix: '#include <crypt.h>')
		libcrypt = [ compiler.find_library('crypt') ]
		conf_data.set('HAVE_CRYPT_R', 1)
	# crypt in default libs?
	elif compiler.has_function('crypt', args: defs, prefix: '#include <crypt.h>')
		conf_data.set('HAVE_CRYPT', 1)
	# crypt in -lcrypt ?
	elif compiler.has_function('crypt', args: defs + ['-lcrypt'], prefix: '#include <crypt.h>')
		libcrypt = [ compiler.find_library('crypt') ]
		conf_data.set('HAVE_CRYPT', 1)
	endif
elif conf_data.get('HAVE_UNISTD_H')
	# crypt in default libs?
	if compiler.has_function('crypt', args: defs, prefix: '#include <unistd.h>')
		conf_data.set('HAVE_CRYPT', 1)
	# crypt in -lcrypt ?
	elif compiler.has_function('crypt', args: defs + ['-lcrypt'], prefix: '#include <unistd.h>')
		libcrypt = [ compiler.find_library('crypt') ]
		conf_data.set('HAVE_CRYPT', 1)
	endif
endif

conf_data.set('HAVE_SOCKLEN_T', compiler.has_type('socklen_t', args: defs, prefix: '#include <sys/socket.h>'))

functions = {
  'arc4random_buf': 'stdlib.h',
  'chroot': 'unistd.h',
  'copy_file_range': 'unistd.h',
  'epoll_ctl': 'sys/epoll.h',
  'explicit_bzero': 'strings.h',
  'explicit_memset': 'string.h',
  'fork': 'unistd.h',
  'getentropy': 'sys/random.h',
  'getloadavg': 'stdlib.h',
  'getrandom': 'linux/random.h',
  'getrlimit': 'sys/resource.h',
  'getuid': 'unistd.h',
  'gmtime_r': 'time.h',
  'inet_aton': 'arpa/inet.h',
  'inet_pton': 'arpa/inet.h',
  'issetugid': 'unistd.h',
  'jrand48': 'stdlib.h',
  'kqueue': 'sys/event.h',
  'localtime_r': 'time.h',
  'lstat': 'sys/stat.h',
  'madvise': 'sys/mman.h',
  'malloc_trim': 'malloc.h',
  'mallopt': 'malloc.h',
  'mempcpy': 'string.h',
  'memset_s': 'string.h',
  'mkostemp': 'stdlib.h',
  'mmap': 'sys/mman.h',
  'pipe2': 'unistd.h',
  'poll': 'poll.h',
  'posix_spawn': 'spawn.h',
  'posix_spawn_file_actions_addclosefrom_np': 'spawn.h',
  'posix_spawn_file_actions_addfchdir_np': 'spawn.h',
  'pread': 'unistd.h',
  'preadv': 'sys/uio.h',
  'preadv2': 'sys/uio.h',
  'pwrite': 'unistd.h',
  'pwritev': 'sys/uio.h',
  'sendfile': 'sys/sendfile.h',
  'sigaction': 'signal.h',
  'signal': 'signal.h',
  'splice': 'fcntl.h',
  'srandom': 'stdlib.h',
  'strerror_r': 'string.h',
  'timegm': 'time.h',
  'writev': 'sys/uio.h',
}

foreach f, h : functions
  conf_data.set('HAVE_@0@'.format(f.underscorify().to_upper()), compiler.has_header_symbol(h, f, args: defs))
endforeach

if not(conf_data.get('HAVE_POLL'))
conf_data.set('HAVE_SYS_SELECT_H', compiler.has_header('sys/select.h'))
conf_data.set('HAVE_SELECT', compiler.has_function('select', args: defs))
endif

if target_machine.system() == 'sunos'
conf_data.set('HAVE_PORT_H', compiler.has_header('port.h'))
conf_data.set('HAVE_PRIV_H', compiler.has_header('priv.h'))
conf_data.set('HAVE_SYS_DEVPOLL_H', compiler.has_header('sys/devpoll.h'))
conf_data.set('HAVE_SYS_FILIO_H', compiler.has_header('sys/filio.h'))
conf_data.set('HAVE_PORT_CREATE', compiler.has_function('port_create', args: defs))
conf_data.set('HAVE_SENDFILEV', compiler.has_function('sendfilev', args: defs))
conf_data.set('HAVE_SETPFLAGS', compiler.has_function('setpflags', args: defs))
endif

conf_data.set('SIZEOF_LONG', compiler.sizeof('long', args: defs))
conf_data.set('SIZEOF_OFF_T', compiler.sizeof('off_t', args: defs))

conf_data.set('HAVE_CLOCK_GETTIME', compiler.has_function('clock_gettime', args: defs, prefix: '#include <time.h>'))
clock_lib = []
if not conf_data.get('HAVE_CLOCK_GETTIME')
  rt = compiler.find_library('rt', required: false)
  conf_data.set('HAVE_CLOCK_GETTIME', compiler.has_function('clock_gettime', args: defs, dependencies: rt, prefix: '#include <time.h>'))
  if conf_data.get('HAVE_CLOCK_GETTIME')
    clock_lib = rt
  else
    threads = dependency('threads', required: false)
    conf_data.set('HAVE_CLOCK_GETTIME', compiler.has_function('clock_gettime', args: defs, dependencies: threads, prefix: '#include <time.h>'))
    if conf_data.get('HAVE_CLOCK_GETTIME')
      clock_lib = threads
    endif
  endif
endif

libelftc = []
if compiler.has_function('elftc_copyfile', args: defs + ['-lelftc'], prefix: '#include <libelftc.h>')
	conf_data.set('HAVE_ELFTC_COPYFILE', true)
	libelftc = [ compiler.find_library('elftc') ]
endif

conf_data.set('HAVE_IPV6', compiler.compiles('''
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netinet/in.h>

	int main() {
		struct sockaddr_in6 s; struct in6_addr t=in6addr_any; int i=AF_INET6; s; t.s6_addr[0] = 0;
		return 0;
	}
''',
	name: 'IPv6 support',
	args: defs
))

conf_data.set('HAVE_WEAK_SYMBOLS', compiler.compiles('''
	__attribute__((weak)) void __dummy(void *x) { }
	int main() {
		void *x;
		__dummy(x);
	}
''',
	name: 'weak symbols',
	args: defs
))

conf_data.set('HAVE_STRUCT_TM_GMTOFF', compiler.compiles('''
	#include <time.h>
	int main(void) {
		struct tm t;
		t.tm_gmtoff = 0;
		return 0;
	}
''',
	name: 'struct tm gmt offset',
	args: defs
))

conf_data.set('LIGHTTPD_VERSION_ID', ''.join(['0x104', meson.project_version().split('.')[2]]))
conf_data.set_quoted('PACKAGE_NAME', meson.project_name())
conf_data.set_quoted('PACKAGE_VERSION', meson.project_version())
conf_data.set_quoted('LIBRARY_DIR', moduledir)

conf_data.set('LIGHTTPD_STATIC', get_option('build_static'))
libdl = []
if not(get_option('build_static'))
	if target_machine.system() != 'windows'
		libdl = [ compiler.find_library('dl', required: false) ]
		if not(compiler.has_function('dlopen', args: defs, dependencies: libdl, prefix: '#include <dlfcn.h>'))
			error('Couldn\'t find dlfcn.h or dlopen in lib dl')
		endif
	endif
endif

libbrotli = dependency('libbrotlienc', required: get_option('with_brotli'))
conf_data.set('HAVE_BROTLI_ENCODE_H', libbrotli.found())
conf_data.set('HAVE_BROTLI', libbrotli.found())

libbz2 = compiler.find_library('bz2', required: get_option('with_bzip'))
conf_data.set('HAVE_BZLIB_H', libbz2.found())
conf_data.set('HAVE_LIBBZ2', libbz2.found())

libdbi = dependency('dbi', required: get_option('with_dbi'))
conf_data.set('HAVE_DBI', libdbi.found())

libfam = []
if not conf_data.get('HAVE_SYS_INOTIFY_H')
	libfam = compiler.find_library('fam', required: get_option('with_fam'))
	conf_data.set('HAVE_FAM_H', libfam.found())
endif

libdeflate = dependency('libdeflate', required: get_option('with_libdeflate'))
conf_data.set('HAVE_LIBDEFLATE', libdeflate.found())

libmaxminddb = dependency('libmaxminddb', required: get_option('with_maxminddb'))

libkrb5 = dependency('krb5', required: get_option('with_krb5'))
libgssapi_krb5 = dependency('krb5-gssapi', required: get_option('with_krb5'))
conf_data.set('HAVE_KRB5', libkrb5.found() and libgssapi_krb5.found())

libldap = compiler.find_library('ldap', required: get_option('with_ldap'))
liblber = compiler.find_library('lber', required: get_option('with_ldap'))
conf_data.set('HAVE_LDAP_H', libldap.found())
conf_data.set('HAVE_LIBLDAP', libldap.found())
conf_data.set('HAVE_LBER_H', liblber.found())
conf_data.set('HAVE_LIBLBER', liblber.found())

libpam = compiler.find_library('pam', required: get_option('with_pam'))
conf_data.set('HAVE_PAM', libpam.found())

libunwind = dependency('libunwind', required: get_option('with_libunwind'))

liblua = []
if get_option('with_lua')
	lua_version = get_option('lua_version')
	if (lua_version != '')
		liblua = dependency(lua_version, required: true)
	else
		found_lua = false
		foreach l: ['lua54','lua5.4','lua-5.4','lua53','lua5.3','lua-5.3','lua52','lua5.2','lua-5.2','lua51','lua5.1','lua-5.1','lua']
			liblua = dependency(l, required: false)
			if not(liblua.found())
				liblua = compiler.find_library(l, required: false)
				if not(liblua.found())
					continue
				endif
				foreach ib: include_base_paths
					i = join_paths(ib, l)
					if compiler.has_header(join_paths(i, 'lua.h'))
						liblua += [ declare_dependency(include_directories: include_directories(i)) ]
						break
					endif
				endforeach
			endif
			found_lua = true
			break
		endforeach
		if not(found_lua)
			error('Couldn\'t find any lua library')
		endif
	endif
	liblua = [ liblua ]
	conf_data.set('HAVE_LUA_H', true)
endif

libmysqlclient = dependency('libmariadb', required: get_option('with_mysql'))
conf_data.set('HAVE_MYSQL', libmysqlclient.found())

libssl = []
libcrypto = []
libsslcrypto = []
libgnutls = []
libmbedtls = []
libmbedcrypto = []
libmbedx509 = []
libwolfssl = []
if get_option('with_openssl')
	# manual search:
	# header: openssl/ssl.h
	# function: SSL_new (-lssl)
	# function: RAND_bytes (-lcrypto)
	libssl = [ dependency('libssl') ]
	libsslcrypto = [ dependency('libcrypto') ]
	libcrypto = [ dependency('libcrypto') ]
	conf_data.set('HAVE_OPENSSL_SSL_H', true)
	conf_data.set('HAVE_LIBSSL', true)
endif
if get_option('with_wolfssl')
	# manual search:
	# header: wolfssl/ssl.h
	# function: wolfSSL_Init (-lwolfssl)
	libwolfssl = [ dependency('wolfssl') ]
	libcrypto = [ dependency('wolfssl') ]
	conf_data.set('HAVE_WOLFSSL_SSL_H', true)
endif
if get_option('with_mbedtls')
	# manual search:
	# header: mbedtls/ssl.h
	# function: mbedtls_ssl_init (-lmbedtls)
	# function: mbedtls_x509_get_name (-lmbedx509)
	# function: mbedtls_base64_encode (-lmbedcrypto)
	libmbedtls = [ compiler.find_library('mbedtls') ]
	libmbedx509 = [ compiler.find_library('mbedx509') ]
	libmbedcrypto = [ compiler.find_library('mbedcrypto') ]
	if compiler.get_define('FORCE_WOLFSSL_CRYPTO') == ''
	  libcrypto = [ compiler.find_library('mbedcrypto') ]
	endif
	conf_data.set('HAVE_LIBMBEDCRYPTO', true)
endif
if get_option('with_nettle')
	# manual search:
	# header: nettle/nettle-types.h
	# function: nettle_md5_init (-lnettle)
	if compiler.get_define('FORCE_WOLFSSL_CRYPTO') == '' and compiler.get_define('FORCE_MBEDTLS_CRYPTO') == ''
	  libcrypto = [ dependency('nettle') ]
	  conf_data.set('HAVE_NETTLE_NETTLE_TYPES_H', true)
	endif
endif
if get_option('with_gnutls')
	# manual search:
	# header: gnutls/gnutls.h
	# function: gnutls_check_version (-lgnutls)
	libgnutls = [ dependency('gnutls') ]
	conf_data.set('HAVE_GNUTLS_CRYPTO_H', true)
	if not(get_option('with_openssl')) and not(get_option('with_wolfssl')) and not(get_option('with_mbedtls')) and not(get_option('with_nettle'))
	  libcrypto = [ dependency('gnutls') ]
	endif
endif
libssl3 = []
libsmime3 = []
libnss3 = []
libnssutil3 = []
if get_option('with_nss')
	# manual search:
	# header: nss3/nss.h
	# function: NSSSSL_GetVersion (-lssl3)
	# function: NSSSMIME_GetVersion (-lsmime3)
	# function: NSS_GetVersion (-lnss3)
	# function: NSSUTIL_GetVersion (-lnssutil3)
	libnss3 = [ dependency('nss') ]
	#libssl3 = [ compiler.find_library('ssl3') ]
	#libsmime3 = [ compiler.find_library('smime3') ]
	#libnss3 = [ compiler.find_library('nss3') ]
	#libnssutil3 = [ compiler.find_library('nssutil3') ]
	conf_data.set('HAVE_NSS3_NSS_H', true)
	if not(get_option('with_openssl')) and not(get_option('with_wolfssl')) and not(get_option('with_mbedtls')) and not(get_option('with_nettle')) and not(get_option('with_gnutls'))
	  libcrypto = [ dependency('nss') ]
	endif
endif
if get_option('with_nss')
	# manual search:
	# header: nss/nss.h
	conf_data.set('HAVE_NSS_NSS_H', true)
endif

libpcre = []
pcre = get_option('with_pcre')
if pcre == 'auto' or get_option('with_pcre2')
	 pcre = 'pcre2'
endif

if pcre == 'pcre2'
	libpcre = dependency('libpcre2-8', required: get_option('with_pcre') == 'pcre2' or get_option('with_pcre2'))
	conf_data.set('HAVE_PCRE2_H', libpcre.found())
	conf_data.set('HAVE_PCRE', libpcre.found())
	if not libpcre.found()
		pcre = 'pcre'
	endif
endif

if pcre == 'pcre'
	libpcre = dependency('libpcre', required: pcre == 'pcre')
	conf_data.set('HAVE_PCRE_H', libpcre.found())
	conf_data.set('HAVE_PCRE', libpcre.found())
	if not libpcre.found()
		error('Neither pcre2 nor pcre was found when with_pcre was not disabled')
	endif
endif

libpq = dependency('libpq', required: get_option('with_pgsql'))
conf_data.set('HAVE_PGSQL', libpq.found())

libsasl = dependency('libsasl2', required: get_option('with_sasl'))
conf_data.set('HAVE_SASL', libsasl.found())

#if get_option('with_valgrind')
#endif

libxml2 = dependency('libxml-2.0', required: get_option('with_webdav_props'))
libsqlite3 = dependency('sqlite3', required: get_option('with_webdav_props'))
conf_data.set('HAVE_LIBXML2', libxml2.found())
conf_data.set('HAVE_LIBXML_H', libxml2.found())
conf_data.set('HAVE_SQLITE3_H', libsqlite3.found())

libattr = []
if get_option('with_xattr')
    if compiler.has_function('getxattr',
		args: defs,
		prefix: '''
			#include <sys/types.h>
			#include <sys/xattr.h>
		'''
    )
	conf_data.set('HAVE_SYS_XATTR_H', true)
	conf_data.set('HAVE_XATTR', true)
    elif compiler.has_function('extattr_get_file',
		args: defs,
		prefix: '''
			#include <sys/types.h>
			#include <sys/extattr.h>
		'''
    )
	conf_data.set('HAVE_SYS_EXTATTR_H', true)
	conf_data.set('HAVE_EXTATTR', true)
    else
	libattr = [ compiler.find_library('attr') ]
	if not(compiler.has_function('attr_get',
		args: defs,
		dependencies: libattr,
		prefix: '''
			#include <sys/types.h>
			#include <attr/attributes.h>
		'''
	))
		error('Couldn\'t find attr/attributes.h or attr_get in lib attr')
	endif
	conf_data.set('HAVE_ATTR_ATTRIBUTES_H', true)
	conf_data.set('HAVE_XATTR', true)
    endif
endif

libxxhash = dependency('libxxhash', required: get_option('with_xxhash'))
conf_data.set('HAVE_XXHASH_H', libxxhash.found())

libz = dependency('zlib', required: get_option('with_zlib'))
conf_data.set('HAVE_ZLIB_H', libz.found())
conf_data.set('HAVE_LIBZ', libz.found())

libzstd = dependency('libzstd', required: get_option('with_zstd'))
conf_data.set('HAVE_ZSTD_H', libzstd.found())
conf_data.set('HAVE_ZSTD', libzstd.found())

configure_file(
	output : 'config.h',
	configuration : conf_data,
)

common_src = files(
	'algo_md5.c',
	'algo_sha1.c',
	'algo_splaytree.c',
	'array.c',
	'base64.c',
	'buffer.c',
	'burl.c',
	'chunk.c',
	'configfile-glue.c',
	'http_etag.c',
	'fdevent.c',
	'fdevent_fdnode.c',
	'fdlog_maint.c',
	'fdlog.c',
	'gw_backend.c',
	'http_cgi.c',
	'http_chunk.c',
	'http_date.c',
	'http_header.c',
	'http_kv.c',
	'http-header-glue.c',
	'keyvalue.c',
	'log.c',
	'rand.c',
	'plugin.c',
	'reqpool.c',
	'request.c',
	'ck.c',
	'sock_addr.c',
	'stat_cache.c',
	'sys-setjmp.c',
)

if target_machine.system() == 'windows'
common_src += files(
	'fdevent_win32.c',
	'fs_win32.c',
)
endif

main_src = files(
	'configfile.c',
	'connections.c',
	'data_config.c',
	'h1.c',
	'sock_addr_cache.c',
	'fdevent_impl.c',
	'http_range.c',
	'network_write.c',
	'network.c',
	'response.c',
	'server.c',
)

builtin_mods = files(
  'mod_rewrite.c',
  'mod_redirect.c',
  'mod_access.c',
  'mod_alias.c',
  'mod_indexfile.c',
  'mod_staticfile.c',
  'mod_setenv.c',
  'mod_expire.c',
  'mod_simple_vhost.c',
  'mod_evhost.c',
  'mod_fastcgi.c',
  'mod_scgi.c',
)

if get_option('build_static')
        builtin_mods += files(
          'mod_accesslog.c',
          'mod_ajp13.c',
          'mod_auth.c', 'mod_auth_api.c',
          'mod_authn_file.c',
          'mod_cgi.c',
          'mod_deflate.c',
          'mod_dirlisting.c',
          'mod_extforward.c',
          'mod_proxy.c',
          'mod_rrdtool.c',
          'mod_sockproxy.c',
          'mod_ssi.c',
          'mod_status.c',
          'mod_userdir.c',
          'mod_vhostdb.c', 'mod_vhostdb_api.c',
          'mod_webdav.c',
          'mod_wstunnel.c',
        )
endif

lemon = executable('lemon',
	sources: 'lemon.c',
	native: true,
)
# generator doesn't handle additional "input dependencies" like lempar.c
# => use custom_target
configparser = custom_target('configparser',
	input:  ['configparser.y', 'lempar.c'],
	output: ['configparser.c', 'configparser.h'],
	command: [lemon, '-q', '-d@OUTDIR@', '-T@INPUT1@', '@INPUT0@'],
)

common_cflags = defs + [
	'-DHAVE_CONFIG_H',
]

if compiler.get_id() == 'gcc' or compiler.get_id() == 'clang'
	common_cflags += [
		'-pipe',
		'-Wall',
		'-g',
		'-Wshadow',
		'-W',
		'-pedantic',
	]
	if get_option('build_extra_warnings')
		common_cflags += get_option('warn_cflags').split()
	endif
endif

common_flags = [ declare_dependency(
	compile_args: common_cflags,
	# tests also use common_flags, and need this
	include_directories: include_directories('.'),
) ]

lighttpd_flags = []
lighttpd_angel_flags = []

if get_option('build_static')
	lighttpd_flags += [ libcrypt, libbz2, libz, libzstd, libbrotli, libdeflate, libelftc ]
else
	if target_machine.system() == 'windows' or target_machine.system() == 'cygwin'
		if (compiler.get_id() == 'gcc' or compiler.get_id() == 'clang')
			lighttpd_flags += [ declare_dependency(
				link_args: [
					'-Wl,--export-all-symbols',
				],
			) ]
		endif
	endif
endif
if (compiler.get_id() == 'gcc' or compiler.get_id() == 'clang') and target_machine.system() != 'darwin' and target_machine.system() != 'sunos' and target_machine.system() != 'windows' and target_machine.system() != 'cygwin'
	lighttpd_flags += [ declare_dependency(
		link_args: [
			'-Wl,-export-dynamic',
		],
	) ]
endif

executable('lighttpd-angel',
	sources: 'lighttpd-angel.c',
	dependencies: common_flags + lighttpd_angel_flags,
	c_args: ['-DSBIN_DIR="' + sbindir + '"'],
	install: true,
	install_dir: sbindir,
)

executable('lighttpd', configparser,
	sources: common_src + main_src + builtin_mods,
	dependencies: [ common_flags, lighttpd_flags
		, libattr
		, libcrypto
		, libdl
		, libfam
		, libpcre
		, libunwind
		, libxxhash
		, socket_libs
		, clock_lib
	],
	install: true,
	install_dir: sbindir,
)

test('test_common', executable('test_common',
	sources: [
		't/test_common.c',
		't/test_array.c',
		't/test_base64.c',
		't/test_buffer.c',
		't/test_burl.c',
		't/test_http_header.c',
		't/test_http_kv.c',
		't/test_http_range.c',
		't/test_keyvalue.c',
		't/test_request.c',
		'log.c',
		'fdlog.c',
		'sock_addr.c',
		'ck.c',
	],
	dependencies: [ common_flags
		, libpcre
		, libunwind
		, socket_libs
		, clock_lib
	],
	build_by_default: false,
))

test('test_configfile', executable('test_configfile',
	sources: [
		't/test_configfile.c',
		'buffer.c',
		'array.c',
		'data_config.c',
		'http_header.c',
		'http_kv.c',
		'log.c',
		'fdlog.c',
		'sock_addr.c',
		'ck.c',
	],
	dependencies: [ common_flags
		, libpcre
		, libunwind
		, socket_libs
		, clock_lib
	],
	build_by_default: false,
))

test('test_mod', executable('test_mod',
	sources: [
		common_src,
		't/test_mod.c',
		't/test_mod_access.c',
		't/test_mod_alias.c',
		't/test_mod_evhost.c',
		't/test_mod_expire.c',
		't/test_mod_indexfile.c',
		't/test_mod_simple_vhost.c',
		't/test_mod_ssi.c',
		't/test_mod_staticfile.c',
		't/test_mod_userdir.c',
	],
	dependencies: [ common_flags, lighttpd_flags
		, libattr
		, libcrypto
		, libdl
		, libfam
		, libpcre
		, libunwind
		, libxxhash
		, socket_libs
		, clock_lib
	],
	build_by_default: false,
))

if get_option('build_static')
modules = []
else
modules = [
	[ 'mod_accesslog', [ 'mod_accesslog.c' ] ],
	[ 'mod_ajp13', [ 'mod_ajp13.c' ] ],
	[ 'mod_auth', [ 'mod_auth.c', 'mod_auth_api.c' ], [ libcrypto ] ],
	[ 'mod_authn_file', [ 'mod_authn_file.c' ], [ libcrypt, libcrypto ] ],
	[ 'mod_cgi', [ 'mod_cgi.c' ] ],
	[ 'mod_deflate', [ 'mod_deflate.c' ], [ libbz2, libz, libzstd, libbrotli, libdeflate ] ],
	[ 'mod_dirlisting', [ 'mod_dirlisting.c' ] ],
	[ 'mod_extforward', [ 'mod_extforward.c' ] ],
	[ 'mod_h2', [ 'h2.c', 'ls-hpack/lshpack.c', 'algo_xxhash.c' ], [ libxxhash ] ],
	[ 'mod_proxy', [ 'mod_proxy.c' ], socket_libs ],
	[ 'mod_rrdtool', [ 'mod_rrdtool.c' ] ],
	[ 'mod_sockproxy', [ 'mod_sockproxy.c' ] ],
	[ 'mod_ssi', [ 'mod_ssi.c' ], socket_libs ],
	[ 'mod_status', [ 'mod_status.c' ] ],
	[ 'mod_userdir', [ 'mod_userdir.c' ] ],
	[ 'mod_vhostdb', [ 'mod_vhostdb.c', 'mod_vhostdb_api.c' ] ],
	[ 'mod_webdav', [ 'mod_webdav.c' ], [ libsqlite3, libxml2, libelftc ] ],
	[ 'mod_wstunnel', [ 'mod_wstunnel.c' ], libcrypto ],
]
endif

if get_option('with_lua')
	modules += [
		[ 'mod_magnet', [ 'mod_magnet.c', 'mod_magnet_cache.c', 'algo_hmac.c' ], liblua + libcrypto ],
	]
endif

if libmaxminddb.found()
	modules += [
		[ 'mod_maxminddb', [ 'mod_maxminddb.c' ], libmaxminddb ],
	]
endif

if libmysqlclient.found()
	modules += [
		[ 'mod_vhostdb_mysql', [ 'mod_vhostdb_mysql.c' ], libmysqlclient ],
	]
endif

if libpq.found()
	modules += [
		[ 'mod_vhostdb_pgsql', [ 'mod_vhostdb_pgsql.c' ], libpq ],
	]
endif

if libdbi.found()
	modules += [
		[ 'mod_authn_dbi', [ 'mod_authn_dbi.c' ], [ libcrypt, libdbi, libcrypto ] ],
		[ 'mod_vhostdb_dbi', [ 'mod_vhostdb_dbi.c' ], libdbi ],
	]
endif

if libkrb5.found() and libgssapi_krb5.found()
	modules += [
		[ 'mod_authn_gssapi', [ 'mod_authn_gssapi.c' ], [ libkrb5, libgssapi_krb5 ] ],
	]
endif

if libldap.found() and liblber.found()
	modules += [
		[ 'mod_authn_ldap', [ 'mod_authn_ldap.c' ], [ libldap, liblber ] ],
		[ 'mod_vhostdb_ldap', [ 'mod_vhostdb_ldap.c' ], [ libldap, liblber ] ],
	]
endif

if get_option('with_openssl')
	modules += [
		[ 'mod_openssl', [ 'mod_openssl.c' ], libssl + libsslcrypto ],
	]
endif

if get_option('with_wolfssl')
	modules += [
		[ 'mod_wolfssl', [ 'mod_wolfssl.c' ], libwolfssl ],
	]
endif

if get_option('with_mbedtls')
	modules += [
		[ 'mod_mbedtls', [ 'mod_mbedtls.c' ], libmbedtls + libmbedx509 + libmbedcrypto ],
	]
endif

if get_option('with_nss')
	modules += [
		[ 'mod_nss', [ 'mod_nss.c' ], libssl3 + libsmime3 + libnss3 + libnssutil3 ],
	]
endif

if get_option('with_gnutls')
	modules += [
		[ 'mod_gnutls', [ 'mod_gnutls.c' ], libgnutls ],
	]
endif

if libpam.found()
	modules += [
		[ 'mod_authn_pam', [ 'mod_authn_pam.c' ], libpam ],
	]
endif

if libsasl.found()
	modules += [
		[ 'mod_authn_sasl', [ 'mod_authn_sasl.c' ], libsasl ],
	]
endif

plugin_suffix = []
if (host_machine.system() == 'darwin')
	plugin_suffix = 'so'  # use "so" instead of "dylib"
endif

foreach mod: modules
	mod_name = mod.get(0)
	mod_sources = mod.get(1)
	mod_deps = mod.length() > 2 ? mod.get(2) : []
	shared_module(mod_name,
		sources: mod_sources,
		dependencies: [ common_flags, mod_deps ],
		name_prefix: '',
		name_suffix: plugin_suffix,
		install: true,
		install_dir: moduledir,
	)
endforeach
