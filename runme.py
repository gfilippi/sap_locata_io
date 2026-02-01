#!/usr/bin/env python3

import sys
import getopt
import subprocess
import shlex


def usage():
    print(
        "Usage:\n"
        "  run_main.py --data_dir <path> --results_dir <path> --is_dev <0|1> "
        "[--arrays a1,a2,a3] [--tasks t1,t2,t3]\n\n"
        "Example:\n"
        "  run_main.py --data_dir ./data --results_dir ./results --is_dev 1 "
        "--arrays benchmark2,eigenmike --tasks 1,3,5"
    )


def matlab_cell_array(strings):
    """
    Convert ['a','b'] -> {'a','b'}
    """
    return "{%s}" % ",".join(f"'{s}'" for s in strings)


def matlab_vector(numbers):
    """
    Convert [1,2,3] -> [1 2 3]
    """
    return "[%s]" % " ".join(str(n) for n in numbers)


def main():
    # Defaults (matching MATLAB comments)
    data_dir = None
    results_dir = None
    is_dev = None
    arrays = ['benchmark2', 'eigenmike', 'dicit', 'dummy']
    tasks = [1, 2, 3, 4, 5, 6]

    try:
        opts, _ = getopt.getopt(
            sys.argv[1:],
            "",
            ["data_dir=", "results_dir=", "is_dev=", "arrays=", "tasks="]
        )
    except getopt.GetoptError as e:
        print(e)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt == "--data_dir":
            data_dir = arg
        elif opt == "--results_dir":
            results_dir = arg
        elif opt == "--is_dev":
            is_dev = int(arg)
        elif opt == "--arrays":
            arrays = arg.split(",")
        elif opt == "--tasks":
            tasks = [int(t) for t in arg.split(",")]


    # Print parameters in order (as requested)
    print("Parsed parameters:")
    print(f"data_dir   = {data_dir}")
    print(f"results_dir= {results_dir}")
    print(f"is_dev     = {is_dev}")
    print(f"arrays     = {arrays}")
    print(f"tasks      = {tasks}")


    if data_dir is None or results_dir is None or is_dev is None:
        usage()
        sys.exit(1)

    # Convert to MATLAB/Octave syntax
    arrays_matlab = matlab_cell_array(arrays)
    tasks_matlab = matlab_vector(tasks)

    # Build Octave command
    octave_cmd = (
        f"main('{data_dir}', '{results_dir}', {is_dev}, "
        f"{arrays_matlab}, {tasks_matlab});"
    )

    matlab_cmd = (
        "try, "
        + octave_cmd +
        " catch ME, disp(getReport(ME)), exit(1), end, exit(0);"
    )

    full_cmd = [
        "matlab",
        "-batch",
        matlab_cmd
    ]

    print("\nExecuting Octave command:")
    print(" ".join(shlex.quote(c) for c in full_cmd))
    print("\n==============================================\n")

    # Run 
    subprocess.run(full_cmd, check=True)


if __name__ == "__main__":
    main()
