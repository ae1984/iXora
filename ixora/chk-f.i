/* chk-f.i
 * MODULE
        Trade Finance
 * DESCRIPTION
        Функция проверки наличия файла
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        20/05/2011 id00810
 * BASES
        BANK
 * CHANGES
 */
  function chk-f returns char (input parm1 as char).
      def var v-exist as char init '0'.
      if parm1 ne "" then do:
          input through value( "find " + parm1 + ";echo $?").
          repeat:
              import unformatted v-exist.
          end.
      end.
      return v-exist.
  end function.
