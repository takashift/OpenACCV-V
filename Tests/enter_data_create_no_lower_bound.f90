#ifndef T1
!T1:data,executable-data,construct-independent,V:2.0-2.7
      LOGICAL FUNCTION test1()
        IMPLICIT NONE
        INCLUDE "acc_testsuite.Fh"
        INTEGER :: x !Iterators
        REAL(8),DIMENSION(LOOPCOUNT):: a, b, c, d, e !Data
        INTEGER :: errors = 0

        !Initilization
        SEEDDIM(1) = 1
#       ifdef SEED
        SEEDDIM(1) = SEED
#       endif
        CALL RANDOM_SEED(PUT=SEEDDIM)

        CALL RANDOM_NUMBER(a)
        CALL RANDOM_NUMBER(b)
        c = 0
        CALL RANDOM_NUMBER(d)
        e = 0

        !$acc enter data create(c(:LOOPCOUNT))
        !$acc data copyin(a(1:LOOPCOUNT), b(1:LOOPCOUNT), d(1:LOOPCOUNT)) copyout(e(1:LOOPCOUNT)) present(c(1:LOOPCOUNT))
          !$acc parallel
            !$acc loop
            DO x = 1, LOOPCOUNT
              c(x) = a(x) + b(x)
            END DO
            !$acc loop
            DO x = 1, LOOPCOUNT
              e(x) = c(x) + d(x)
            END DO
          !$acc end parallel
        !$acc end data
        DO x = 1, LOOPCOUNT
          IF (abs(e(x) - (a(x) + b(x) + d(x))) .gt. PRECISION) THEN
            errors = errors + 1
          END IF
        END DO

        IF (errors .eq. 0) THEN
          test1 = .FALSE.
        ELSE
          test1 = .TRUE.
        END IF
      END
#endif

      PROGRAM main
        IMPLICIT NONE
        INTEGER :: failcode, testrun
        LOGICAL :: failed
        INCLUDE "acc_testsuite.Fh"
#ifndef T1
        LOGICAL :: test1
#endif
        failed = .FALSE.
        failcode = 0
#ifndef T1
        DO testrun = 1, NUM_TEST_CALLS
          failed = failed .or. test1()
        END DO
        IF (failed) THEN
          failcode = failcode + 2 ** 0
          failed = .FALSE.
        END IF
#endif
        CALL EXIT (failcode)
      END PROGRAM
