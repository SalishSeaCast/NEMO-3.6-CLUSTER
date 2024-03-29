MODULE trcsms_my_trc
   !!======================================================================
   !!                         ***  MODULE trcsms_my_trc  ***
   !! TOP :   Main module of the MY_TRC tracers
   !!======================================================================
   !! History :   2.0  !  2007-12  (C. Ethe, G. Madec) Original code
   !!----------------------------------------------------------------------
#if defined key_my_trc
   !!----------------------------------------------------------------------
   !!   'key_my_trc'                                               CFC tracers
   !!----------------------------------------------------------------------
   !! trc_sms_my_trc       : MY_TRC model main routine
   !! trc_sms_my_trc_alloc : allocate arrays specific to MY_TRC sms
   !!----------------------------------------------------------------------
   USE par_trc         ! TOP parameters
   USE oce_trc         ! Ocean variables
   USE trc             ! TOP variables
   USE trd_oce
   USE trdtrc

   IMPLICIT NONE
   PRIVATE

   PUBLIC   trc_sms_my_trc       ! called by trcsms.F90 module
   PUBLIC   trc_sms_my_trc_alloc ! called by trcini_my_trc.F90 module

   ! Defined HERE the arrays specific to MY_TRC sms and ALLOCATE them in trc_sms_my_trc_alloc

   !!----------------------------------------------------------------------
   !! NEMO/TOP 3.3 , NEMO Consortium (2010)
   !! $Id: trcsms_my_trc.F90 5385 2015-06-09 13:50:42Z cetlod $
   !! Software governed by the CeCILL licence     (NEMOGCM/NEMO_CeCILL.txt)
   !!----------------------------------------------------------------------
CONTAINS

   SUBROUTINE trc_sms_my_trc( kt )
      !!----------------------------------------------------------------------
      !!                     ***  trc_sms_my_trc  ***
      !!
      !! ** Purpose :   main routine of MY_TRC model
      !!
      !! ** Method  : -
      !!----------------------------------------------------------------------
      !
      INTEGER, INTENT(in) ::   kt   ! ocean time-step index
      INTEGER ::   jn, jk   ! dummy loop index
      REAL(wp), POINTER, DIMENSION(:,:,:) :: ztrmyt
      !!----------------------------------------------------------------------
      !
      IF( nn_timing == 1 )  CALL timing_start('trc_sms_my_trc')
      !
      IF(lwp) WRITE(numout,*)
      IF(lwp) WRITE(numout,*) ' trc_sms_my_trc:  MY_TRC model'
      IF(lwp) WRITE(numout,*) ' ~~~~~~~~~~~~~~'

      IF( l_trdtrc )  CALL wrk_alloc( jpi, jpj, jpk, ztrmyt )

      IF( l_trdtrc ) THEN      ! Save the trends in the ixed layer
          DO jn = jp_myt0, jp_myt1
            ztrmyt(:,:,:) = tra(:,:,:,jn)
            CALL trd_trc( ztrmyt, jn, jptra_sms, kt )   ! save trends
          END DO
          CALL wrk_dealloc( jpi, jpj, jpk, ztrmyt )
      END IF

      DO jn = jp_myt0, jp_myt1
         tra(:, :, :, jpmyt1) = tra(:, :, :, jpmyt1) - REAL(1./86400., wp) * trb(:, :, :, jpmyt1)
         DO jk = 19, jpk
            WHERE (((gphit <  49.44) .OR. (gphit > 49.69) .OR. (gphit > (-1.18_wp * glamt - 97.69_wp))) .AND. &
                 (((glamt > -125.12) .OR. (gphit < 50.14)) .AND. (gphit > (-2.2_wp * glamt - 225.39_wp))))
               trb(:, :, jk, jn) = 1.0_wp
            END WHERE
         END DO
      END DO

      !
      IF( nn_timing == 1 )  CALL timing_stop('trc_sms_my_trc')
      !
   END SUBROUTINE trc_sms_my_trc


   INTEGER FUNCTION trc_sms_my_trc_alloc()
      !!----------------------------------------------------------------------
      !!              ***  ROUTINE trc_sms_my_trc_alloc  ***
      !!----------------------------------------------------------------------
      !
      ! ALLOCATE here the arrays specific to MY_TRC
      ! ALLOCATE( tab(...) , STAT=trc_sms_my_trc_alloc )
      trc_sms_my_trc_alloc = 0      ! set to zero if no array to be allocated
      !
      IF( trc_sms_my_trc_alloc /= 0 ) CALL ctl_warn('trc_sms_my_trc_alloc : failed to allocate arrays')
      !
   END FUNCTION trc_sms_my_trc_alloc


#else
   !!----------------------------------------------------------------------
   !!   Dummy module                                        No MY_TRC model
   !!----------------------------------------------------------------------
CONTAINS
   SUBROUTINE trc_sms_my_trc( kt )             ! Empty routine
      INTEGER, INTENT( in ) ::   kt
      WRITE(*,*) 'trc_sms_my_trc: You should not have seen this print! error?', kt
   END SUBROUTINE trc_sms_my_trc
#endif

   !!======================================================================
END MODULE trcsms_my_trc
