import os
import common.testing

const executable_under_test = testing.prepare_executable('head')

const cmd = testing.new_paired_command('head', executable_under_test)

const test_txt_path = os.join_path(testing.temp_folder, 'test.txt')

fn testsuite_begin() {
	mut f := os.open_file(test_txt_path, 'w')!
	for l in testtxtcontent {
		f.write_string('${l}\n')!
	}
	f.close()
}

fn testsuite_end() {
	os.rm(test_txt_path)!
}

fn test_help_and_version() {
	cmd.ensure_help_and_version_options_work()!
}

fn test_non_existent_file() {
	res := os.execute('${executable_under_test} non-existent-file')
	assert res.exit_code == 1
	assert res.output.trim_space() == 'head: failed to open file "non-existent-file"'
}

fn test_non_existent_files() {
	res := os.execute('${executable_under_test} non-existent-file second-non-existent-file')
	assert res.exit_code == 1
	assert res.output.trim_space() == 'head: failed to open file "non-existent-file"\nhead: failed to open file "second-non-existent-file"'
}

const testtxtcontent = [
	'[0] Line in test text file',
	'[1] Line in test text file',
	'[2] Line in test text file',
	'[3] Line in test text file',
	'[4] Line in test text file',
	'[5] Line in test text file',
	'[6] Line in test text file',
	'[7] Line in test text file',
	'[8] Line in test text file',
	'[9] Line in test text file',
	'[10] Line in test text file',
	'[11] Line in test text file',
	'[12] Line in test text file',
]

fn test_default() {
	res := os.execute('${executable_under_test} ${test_txt_path}')
	assert res.exit_code == 0
	assert res.output.split('\n').filter(it != '') == [
		'[0] Line in test text file',
		'[1] Line in test text file',
		'[2] Line in test text file',
		'[3] Line in test text file',
		'[4] Line in test text file',
		'[5] Line in test text file',
		'[6] Line in test text file',
		'[7] Line in test text file',
		'[8] Line in test text file',
		'[9] Line in test text file',
	]
}

fn test_max_lines_option() {
	res := os.execute('${executable_under_test} ${test_txt_path} -n 4')
	assert res.exit_code == 0
	assert res.output.split('\n').filter(it != '') == [
		'[0] Line in test text file',
		'[1] Line in test text file',
		'[2] Line in test text file',
		'[3] Line in test text file',
	]
}

fn test_max_lines_from_end_option() {
	res := os.execute('${executable_under_test} ${test_txt_path} -n -4')
	assert res.exit_code == 0
	assert res.output.split('\n').filter(it != '') == [
		'[0] Line in test text file',
		'[1] Line in test text file',
		'[2] Line in test text file',
		'[3] Line in test text file',
		'[4] Line in test text file',
		'[5] Line in test text file',
		'[6] Line in test text file',
		'[7] Line in test text file',
		'[8] Line in test text file',
	]
}

fn test_upto_max_bytes() {
	res := os.execute('${executable_under_test} ${test_txt_path} -c 223')
	assert res.exit_code == 0
	assert res.output.split('\n').filter(it != '') == [
		'[0] Line in test text file',
		'[1] Line in test text file',
		'[2] Line in test text file',
		'[3] Line in test text file',
		'[4] Line in test text file',
		'[5] Line in test text file',
		'[6] Line in test text file',
		'[7] Line in test text file',
		'[8] Lin',
	]
}

fn test_upto_max_bytes_from_end_option() {
	res := os.execute('${executable_under_test} ${test_txt_path} -c -312')
	assert res.exit_code == 0
	assert res.output.split('\n').filter(it != '') == [
		'[0] Line in test text file',
		'[1] Line in tes',
	]
}
