!
! Copyright (c) 2013      Los Alamos National Security, LLC.
!                         All rights reserved.
!

! my very first fortran app -- don't laugh too hard...

program QUOFortF90
    implicit none
    ! include quof and mpif
    include "quof.h"
    include "mpif.h"

    ! holds the "quo context" that is passed around (must be the same size as
    ! the system's C pointer type.
    integer*8 :: quo
    ! holds libquo return codes, holds mpi return codes
    integer*4 qerr, ierr
    ! libquo uses standard ints. these sizes must be the same as the system's
    ! C int type.
    integer*4 :: quovmaj, quovmin
    integer*4 :: initialized, nnodes, nsockets, ncores, npus, bound, noderank

    ! init mpi because quo needs it
    call MPI_INIT
    ! get libquo's version info
    call QUO_VERSION(quovmaj, quovmin, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        stop
    end if
    ! construct the quo context.
    call QUO_CONSTRUCT(quo, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_CONSTRUCT failure: err = ', qerr
        stop
    end if
    ! init the newly constructed context
    call QUO_INIT(quo, qerr)
    if (QUO_SUCCESS .NE. qerr .AND. QUO_SUCCESS_ALREADY_DONE .NE. qerr) then
        print *, 'QUO_INIT failure: err = ', qerr
        stop
    end if
    ! exercise the interface by checking if the context is initialized.
    call QUO_INITIALIZED(quo, initialized, qerr)
    if (initialized .EQ. 1) then
        print *, '### libquo is initialized'
    else
        print *, '### libquo is not initialized'
        stop
    end if

    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! libquo is initialized, so we can get to work
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! what is my node rank
    call QUO_NODERANK(quo, noderank, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_NODERANK failure: err = ', qerr
        stop
    end if
    ! how many nodes are in our job
    call QUO_NNODES(quo, nnodes, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_NNODES failure: err = ', qerr
        stop
    end if
    ! how many sockets are on this system
    call QUO_NSOCKETS(quo, nsockets, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_NSOCKETS failure: err = ', qerr
        stop
    end if
    ! how many cores are on this system
    call QUO_NCORES(quo, ncores, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_NCORES failure: err = ', qerr
        stop
    end if
    ! how many processing units (PUs) are on this system
    call QUO_NPUS(quo, npus, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_NPUS failure: err = ', qerr
        stop
    end if
    ! one rank per node will emit this info
    if (0 .EQ. noderank) then
        print *, '### quoversion: ', quovmaj, quovmin
        print *, '### nnodes    : ', nnodes
        print *, '### nsockets  : ', nsockets
        print *, '### ncores    : ', ncores
        print *, '### npus      : ', npus
    end if
    ! is the process bound (cpu binding)
    call QUO_BOUND(quo, bound, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_BOUND failure: err = ', qerr
        stop
    end if
    if (1 .EQ. bound) then
        print *, '### process bound'
    else
        print *, '### process not bound'
    end if
    ! finalize the quo context (always before MPI_FINALIZE)
    call QUO_FINALIZE(quo, qerr)
    if (QUO_SUCCESS .NE. qerr) then
        print *, 'QUO_FINALIZE failure: err = ', qerr
        stop
    end if
    ! finalize mpi (always after QUO_FINALIZE)
    call MPI_FINALIZE(ierr)

end program QUOFortF90