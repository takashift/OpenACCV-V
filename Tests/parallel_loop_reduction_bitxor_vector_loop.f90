#ifndef T1
!T1:parallel,private,reduction,combined-constructs,loop,V:1.0-2.7
      LOGICAL FUNCTION test1()
        IMPLICIT NONE
        INCLUDE "acc_testsuite.Fh"
        INTEGER :: x, y !Iterators
        INTEGER,DIMENSION(10*LOOPCOUNT):: a !Data
        REAL(8),DIMENSION(10*LOOPCOUNT):: randoms
        INTEGER,DIMENSION(10):: b
        INTEGER :: errors = 0
        INTEGER :: temp

        !Initilization
        SEEDDIM(1) = 1
#       ifdef SEED
        SEEDDIM(1) = SEED
#       endif
        CALL RANDOM_SEED(PUT=SEEDDIM)

        CALL RANDOM_NUMBER(randoms)
        a = FLOOR(randoms*1000000)

        !$acc data copyin(a(1:10*LOOPCOUNT)) copy(b(1:10))
          !$acc parallel loop gang private(temp)
          DO x = 0, 9
            temp = 0
            !$acc loop vector reduction(ieor:temp)
            DO y = 1, LOOPCOUNT
              temp = ieor(temp, a(x * LOOPCOUNT + y))
            END DO
            b(x + 1) = temp
          END DO
        !$acc end data
        
        DO x = 0, 9
          temp = 0
          DO y = 1, LOOPCOUNT
            temp = ieor(temp, a(x * LOOPCOUNT + y))
          END DO
          IF (temp .ne. b(x + 1)) THEN
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
