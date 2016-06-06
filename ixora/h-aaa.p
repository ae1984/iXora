/* h-aaa.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * CHANGES
   14/08/03 nataly добавлена стока  return frame-value.
        02.02.10 marinav - расширение поля счета до 20 знаков
        26/04/2012 evseev - добавил выбор  A)счет  N)Имя  P)РНН  B)ИИН/БИН

*/

/* h-aaa.p
*/
{global.i}

define var vselect as char format "x".
message "Выберите    A)счет  N)Имя  P)РНН  B)ИИН/БИН" update vselect.


if vselect eq "A"  OR VSELECT EQ "а"  or vselect eq "А"  or vselect eq "ф" or vselect eq "Ф"
then do:
{itemlist.i
       &file = "aaa"
       &start = "def var vaaa like aaa.aaa.
               message ' Введите номер счета '  update vaaa.
               find aaa where aaa.aaa eq vaaa no-lock no-error."
       &where = "aaa.aaa begins vaaa and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0 and length(aaa.aaa) = 20"
       &frame = "row 5 centered scroll 1 25 down width 95 overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "aaa"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end."
      &set = "A"}
end.
else if vselect eq "N" OR VSELECT EQ "н" OR VSELECT EQ "Н" or vselect eq "т" or vselect eq "Т"
then do:
{itemlist.i
       &file = "aaa"
       &start = "def var vname like aaa.name.
		      message ' Введите наименование клиента '  update vname."
       &where = "aaa.name begins vname and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0 and length(aaa.aaa) = 20"
       &frame = "row 5 centered scroll 1 25 down width 95 overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "aaa"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end."
       &set = "N"}
end.
else if vselect eq "P" or vselect = "p" or vselect = "П" or vselect = "п" or vselect eq "з" or vselect eq "З"
then do:
{itemlist.i
       &file = "aaa"
       &start = "def var vrnn like cif.jss.
		      message ' Введите РНН ' update vrnn.
              find first cif where cif.jss = trim(vrnn) no-lock no-error.
              if not avail cif then do: message 'РНН' vrnn 'не найден!'. pause 10. return. end."
       &where = "aaa.cif = cif.cif and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0 and length(aaa.aaa) = 20"
       &frame = "row 5 centered scroll 1 25 down width 95 overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "aaa"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end."
       &set = "P"}

end.
else if vselect eq "B"  OR VSELECT EQ "b"   or vselect eq "и" or vselect eq "И"
then do:
{itemlist.i
       &file = "aaa"
       &start = "def var vbin like cif.jss.
		      message ' Введите ИИН/БИН ' update vbin.
              find first cif where cif.bin = trim(vbin) no-lock no-error.
              if not avail cif then do: message 'ИИН/БИН' vbin 'не найден!'. pause 10. return. end."
       &where = "aaa.cif = cif.cif and lookup(aaa.lgr,'551,552,553,554,555,556,557,558,571,572') = 0 and length(aaa.aaa) = 20"
       &frame = "row 5 centered scroll 1 25 down width 95 overlay "
       &findadd = "find lgr where lgr.lgr = aaa.lgr no-lock."
       &flddisp = "aaa.aaa aaa.name aaa.cif lgr.led lgr.des"
       &chkey = "aaa"
       &chtype = "string"
       &index  = "aaa"
       &funadd = "if frame-value = "" "" then do:
		    {imesg.i 9205}.
		    pause 1.
		    next.
		  end."
       &set = "B"}

end.