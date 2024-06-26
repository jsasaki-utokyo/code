#include"cppdefs.h"
!-----------------------------------------------------------------------
!BOP
!
! !ROUTINE: Command line parsing
!
! !INTERFACE:
   module cmdline
!
! !DESCRIPTION:
!
   use gotm

   IMPLICIT NONE
!
! !REVISION HISTORY:
!  Original author(s): Karsten Bolding & Hans Burchard
!
!EOP
!

   public parse_cmdline

   private

contains

!EOC
!-----------------------------------------------------------------------
!BOP
!
! !IROUTINE: Parse the command line
!
! !INTERFACE:
   subroutine parse_cmdline(exe)
      character(len=*), intent(in) :: exe
!
! !DESCRIPTION:
!
! !LOCAL VARIABLES:
   character(len=1024) :: arg
   integer :: n, i, ios
   logical :: file_exists
!EOP
!-----------------------------------------------------------------------
!BOC
   n = command_argument_count()
   i = 1
   do while (i <= n)
      call get_command_argument(i, arg)
      select case (arg)
      case ('-v', '--version')
         call print_version()
         stop
      case ('-h', '--help')
         call print_help(exe)
         stop
      case ('--read_nml')
         read_nml = .true.
      case ('--write_yaml')
         i = i+1
         if (i > n) then
            FATAL 'Error parsing command line options: --write_yaml must be followed by the path of the file to write.'
            stop 2
         end if
         call get_command_argument(i, write_yaml_path)
      case ('--detail')
         i = i+1
         if (i > n) then
            FATAL 'Error parsing command line options: --detail must be followed by the detail level (minimal, default, full) to use in written yaml.'
            stop 2
         end if
         call get_command_argument(i, arg)
         select case (arg)
         case ('0', 'minimal')
            write_yaml_detail = 0
         case ('1', 'default')
            write_yaml_detail = 1
         case ('2', 'full')
            write_yaml_detail = 2
         case default
            FATAL 'Value "' // trim(arg) // '" for --detail not recognized.'
            LEVEL1 'Supported options: minimal (0), default (1), full (2)'
            stop 2
         end select
      case ('--write_schema')
         i = i+1
         if (i > n) then
            FATAL 'Error parsing command line options: --write_schema must be followed by the path of the file to write.'
            stop 2
         end if
         call get_command_argument(i, write_schema_path)
      case ('--output_id')
         i = i+1
         if (i > n) then
            FATAL 'Error parsing command line options: --output_id must be followed by the postfix that is to be appended to the name of each output file.'
            stop 2
         end if
         call get_command_argument(i, output_id)
      case ('-l', '--list_variables')
         list_fields = .true.
      case ('--ignore_unknown_config')
         ignore_unknown_config = .true.
      case default
         if (arg(1:2) == '--') then
            FATAL 'Command line option '//trim(arg)//' not recognized. Use -h to see supported options'
            stop 2
         end if
         yaml_file = arg
         inquire(file=trim(yaml_file),exist=file_exists)
         if (.not. file_exists) then
            FATAL 'Custom configuration file '//trim(arg)//' does not exist.'
            stop 2
         end if
      end select
      i = i+1
   end do

   end subroutine parse_cmdline

   subroutine print_help(exe)
      character(len=*), intent(in) :: exe
      print '(a)', 'Usage: '//exe//' [OPTIONS]'
      print '(a)', ''
      print '(a)', 'Options:'
      print '(a)', ''
      print '(a)', '  -h, --help              print usage information and exit'
      print '(a)', '  -v, --version           print version information'
      print '(a)', '  <yaml_file>             read configuration from file (default gotm.yaml)'
      print '(a)', '  --ignore_unknown_config ignore unknown options encountered in configuration'
      print '(a)', '  -l, --list_variables    list all variables available for output'
      print '(a)', '  --output_id <string>    append to output file names - before extension'
      print '(a)', '  --read_nml              read configuration from namelist files'
      print '(a)', '  --write_yaml <file>     save yaml configuration to file'
      print '(a)', '  --detail <level>        settings to include in saved yaml file (minimal, default, full)'
      print '(a)', '  --write_schema <file>   save configuration schema in xml format to file'
      print '(a)', ''
   end subroutine print_help

end module

!-----------------------------------------------------------------------
! Copyright by the GOTM-team under the GNU Public License - www.gnu.org
!-----------------------------------------------------------------------
