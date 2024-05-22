import sys
import argparse
from datetime import datetime

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('filename', metavar='[filename]',
                        help='The filename to read from.')
    parser.add_argument('-b', '--beginning', metavar='<beginning_datetime>', type=datetime.fromisoformat,
                        default=datetime.min,
                        help='The date-time to begin parsing from')
    parser.add_argument('-e', '--end', metavar='<end_datetime>', type=datetime.fromisoformat,
                        default=datetime.max,
                        help='The date-time to stop parsing at')
    args = parser.parse_args()

    if args.filename is None:
        print('You must provide a filename to read from')
        sys.exit(-1)

    log_file  = open(args.filename, 'r')
    log       = log_file.read()
    mcu_check = 'Checking for MCU serial number... '
    results   = {}

    # split test runs by calls to cynthion-test.py
    test_runs = log.split(' cynthion-test.py')
    for t in range(len(test_runs)):
        test = test_runs[t]
        # skip first test
        if t != 0:
            # date strings are 19 characters long and happen right before the cynthion-test.py split
            if test_runs[t-1].startswith('2024', -19):
                test_time = datetime.strptime(test_runs[t-1].split('\n')[-1].strip(), '%Y-%m-%d %H:%M:%S')
            # handling beginning section of gsg8/9 logs with older version of test date output
            else:
                test_time_text = test_runs[t-1].split(' MDT\ncyntest')[0].split('\n')[-1].split(' ')
                year   = int(test_time_text[3])
                day    = int(test_time_text[1])
                hour   = int(test_time_text[-2].split(':')[0])
                minute = int(test_time_text[-2].split(':')[1])
                second = int(test_time_text[-2].split(':')[2])
                if 'PM' in test_time_text:
                    hour += 12
                # these test runs only happened in April, skipping month string->int conversion table
                test_time = datetime(year, 4, day, hour, minute, second)

            # obtain result and associated device serial number of each test run
            if '\nFAIL' in test:
                code = test.split('\nFAIL ')[1].split('\n')[0]
            elif '\nPASS: All tests completed' in test:
                code = 'PASS'
            else:
                code = None
            if mcu_check in test:
                serial = test.split(mcu_check)[1].split(',')[0]
            else:
                serial = None

            # keep track of every test result and associate a timestamp and
            # device serial number to each result
            if test_time > args.beginning and test_time < args.end:
                if code is not None and code in results.keys():
                    results[code][0] += 1
                    if serial not in results[code][1]:
                        results[code][1].append(serial)
                elif code is not None:
                    results[code] = [1, [serial]]
    # sort by number of occurences of each fail code
    sorted_results = dict(sorted(results.items(), key=lambda item: item[1][0]))

    # print report
    print(f"{'FAIL CODE' : <15}{'OCCURENCES' : ^15}{'DEVICE(S)'}")
    for fail_code in sorted_results.keys():
        num_occurences = results[fail_code][0]
        devices        = results[fail_code][1]

        print('-------------------------------------------------------------')
        print(f"{fail_code : <15}{num_occurences : ^15}{devices[0]}")
        if len(devices) > 1:
            for device in devices:
                print(f"{device : >56}")


if __name__ == '__main__':
    main()

