import os
import common.testing

// A lot of the following has been lifted directly from os_test.v in vlib,
// since it is a good demonstration of the ideal/canonical method of testing
// functionality that interacts with the file sys.

const (
	// tfolder will contain all the temporary files/subfolders made by
	// the different tests. It would be removed in testsuite_end(), so
	// individual os tests do not need to clean up after themselves.
	tfolder = os.join_path(os.temp_dir(), 'coreutils', 'mkdir_test')
)

fn testsuite_begin() {
	eprintln('testsuite_begin, tfolder = ${tfolder}')
	os.rmdir_all(tfolder) or {}
	assert !os.is_dir(tfolder)
	os.mkdir_all(tfolder) or { panic(err) }
	os.chdir(tfolder) or {}
	assert os.is_dir(tfolder)
}

fn testsuite_end() {
	os.chdir(os.wd_at_startup) or {}
	os.rmdir_all(tfolder) or {}
	assert !os.is_dir(tfolder)
	eprintln('testsuite_end  , tfolder = ${tfolder} removed.')
}

const executable_under_test = testing.prepare_executable('mkdir')

const cmd = testing.new_paired_command('mkdir', executable_under_test)

fn test_help_and_version() {
	cmd.ensure_help_and_version_options_work()!
}

fn test_default_create_single_dir() {
	test_dir_to_make := 'testdir'
	res := os.execute('${executable_under_test} ${test_dir_to_make}')
	assert res.exit_code == 0
	assert res.output.trim_space() == ''
	assert testing.check_dir_exists(test_dir_to_make)
	os.rmdir_all(test_dir_to_make) or { eprintln("failed to remove '${test_dir_to_make}'") }
}

fn test_default_create_multiple_dirs() {
	first_test_dir_to_make := 'testdir'
	second_test_dir_to_make := 'secondtestdir'
	res := os.execute('${executable_under_test} ${first_test_dir_to_make} ${second_test_dir_to_make}')
	assert res.exit_code == 0
	assert res.output.trim_space() == ''
	assert testing.check_dir_exists(first_test_dir_to_make)
	assert testing.check_dir_exists(second_test_dir_to_make)

	os.rmdir_all(first_test_dir_to_make) or {
		eprintln("failed to remove '${first_test_dir_to_make}'")
	}
	os.rmdir_all(second_test_dir_to_make) or {
		eprintln("failed to remove '${second_test_dir_to_make}'")
	}
}

fn test_default_create_multiple_dirs_with_verbose() {
	first_test_dir_to_make := 'testdir'
	second_test_dir_to_make := 'secondtestdir'
	res := os.execute('${executable_under_test} -v ${first_test_dir_to_make} ${second_test_dir_to_make}')
	assert res.exit_code == 0
	assert res.output.trim_space() == "mkdir: created directory 'testdir'\nmkdir: created directory 'secondtestdir'"
	assert testing.check_dir_exists(first_test_dir_to_make)
	assert testing.check_dir_exists(second_test_dir_to_make)

	os.rmdir_all(first_test_dir_to_make) or {
		eprintln("failed to remove '${first_test_dir_to_make}'")
	}
	os.rmdir_all(second_test_dir_to_make) or {
		eprintln("failed to remove '${second_test_dir_to_make}'")
	}
}

fn test_create_dir_with_parents_and_flag() {
	test_dir_to_make := os.join_path('parent-one', 'child-one', 'last-child')
	res := os.execute('${executable_under_test} -p ${test_dir_to_make}')
	assert res.exit_code == 0
	assert res.output.trim_space() == ''
	assert testing.check_dir_exists(test_dir_to_make)
	os.rmdir_all(test_dir_to_make) or { eprintln("failed to remove '${test_dir_to_make}'") }
}

fn test_create_dir_with_parents_without_flag_fails() {
	test_dir_to_make := os.join_path('parent-two', 'child-two', 'last-child')
	res := os.execute('${executable_under_test} ${test_dir_to_make}')
	assert res.exit_code == 1
	assert res.output.trim_space() == "mkdir: cannot create directory 'parent-two/child-two/last-child': No such file or directory"
	assert !testing.check_dir_exists(test_dir_to_make)
	os.rmdir_all(test_dir_to_make) or { eprintln("failed to remove '${test_dir_to_make}'") }
}
