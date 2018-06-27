// This is needed to be able to run with suid enabled, as most modern linuxes
// don't honoor it on scripts (shell, python, ...) due to security reasons.
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

// This path is hardcoded because we don't need it to be flexible, and that
// simplifies this program security-wise.
char *VENV_PATH = "/virtualenv/";
char *CODE_PATH = "/code/";


int main (int argc, char *argv[]) {
    char *chown_argv[] = {
        "/usr/bin/chown",
        "--recursive",
        NULL,
        // This previous NULL will be replaced by the <uid:gid> passed as
        // argument.
        NULL,
        // This previous NULL will be the directory to chown.
        NULL
        // This last NULL is required to 'flag' the end of the options.
    };
    char *chown_env[] = { NULL };
    int status;
    int cureuid;

    if (argc != 3) {
        fprintf(
            stderr,
            "Usage: %s --virtualenv|--codedir <user>:<gorup>\n",
            argv[0]
        );
        exit(EXIT_FAILURE);
    }

    // set the user:group parameter
    chown_argv[2] = argv[2];

    if (strcmp(argv[1], "--virtualenv") == 0) {
        // virtualenv permissions
        chown_argv[3] = VENV_PATH;
        execve(chown_argv[0], chown_argv, chown_env);
    } else if (strcmp(argv[1], "--codedir") == 0) {
        // code dir permissions
        chown_argv[3] = CODE_PATH;
        execve(chown_argv[0], chown_argv, chown_env);
    } else {
        fprintf(stderr, "Bad option %s.", argv[1]);
        fprintf(
            stderr,
            "Usage: %s --virtualenv|--codedir <user>:<group>\n",
            argv[0]
        );
        exit(EXIT_FAILURE);
    }


}
