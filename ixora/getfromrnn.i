/*getfromrnn.i
 * MODULE
        Название Программного Модуля

        набор функций для получения
        информацию из таблиц РНН
 * DESCRIPTION
        Назначение программы, описание процедур и функций
         - предусмотрел, если в таблице РНН будут "?", чтобы подставлять ""
         - название города включается в адрес.
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
        24/04/2006 u00568 evgeniy
 * CHANGES
        05/07/2006 u00568 evgeniy - добавил is_it_jur_person_rnn, find_rnn
          теперь сначала будет определять физик это или юрик, а потом искать в соответствующих таблицах.
        28/08/2006 u00568 evgeniy - getfioadr если ничего не найдёт - вернет пустое значение
                                  + проверки на 12 символов рнн
                                  + release
        04.09.2012 evseev - иин/бин
 */

/* по заданному рнн если юрик - возвращает true иначе false*/
function is_it_jur_person_rnn returns logical (abin as char).
  /*def var is_it_jur as logical init false.*/
  if length(abin) <> 12 then return ?.
  return(int(SUBSTRING(abin, 5, 1)) >= 4).
end.

/* функция возвращает "" вместо ? или "  "   */
FUNCTION str1 RETURNS character (INPUT parm1 AS character).
    RETURN (if  parm1 = ? then '' else trim(parm1)).
END FUNCTION.


/* функция возвращает ФИО из rnn или rnnu - смотря что доступно */
FUNCTION getfio RETURNS character.
    RETURN (
    if avail rnn then
      str1( rnn.lname ) + " " + str1( rnn.fname ) + " " + str1( rnn.mname )
    else
      if avail rnnu then
        str1( rnnu.busname )
      else
        ''
    ).
END FUNCTION.


/* функция возвращает АДРЕС из rnn или rnnu - смотря что доступно */
FUNCTION getadr RETURNS character.
   RETURN (
    if avail rnn then
      str1(rnn.city1) + ", " + str1(rnn.street1) + ", " + str1(rnn.housen1) + "/" + str1(rnn.apartn1)
    else
      if avail rnnu then
        str1(rnnu.city1) + ", " + str1(rnnu.street1) + ", " + str1(rnnu.housen1) + "/" + str1(rnnu.apartn1)
      else ''
   ).
END FUNCTION.


/* функция возвращает "ФИО, АДРЕС" из rnn или rnnu - смотря что доступно */
FUNCTION getfioadr RETURNS character.
   def var adr as char no-undo.
   def var fio as char no-undo.
   def var spl as char no-undo.
   adr = getadr().
   fio = getfio().
   if adr <> '' and fio <> '' then
     spl = ', '.
   else
     spl = ''.

    RETURN (
     fio + spl + adr
    ).

END FUNCTION.


/* функция ищет rnn или rnnu по заданному РНН */
procedure find_rnn:
   def input parameter vrnn as character.
   release rnn.
   release rnnu.
   if length(vrnn) = 12 then do:
     if is_it_jur_person_rnn(vrnn) then
       find first rnnu where rnnu.bin = vrnn no-lock no-error.
     else
       find first rnn where rnn.bin = vrnn no-lock no-error.
   end.
END.


/* функция возвращает "ФИО, АДРЕС" из rnn или rnnu по заданному РНН */
FUNCTION getfioadr1 RETURNS character (vrnn as character).
  def var ret as character.
  run find_rnn(vrnn).
  ret = getfioadr().
  release rnn.
  release rnnu.
  return ret.
END FUNCTION.

/* функция возвращает "ФИО" из rnn или rnnu по заданному РНН */
function getfio1 returns character (vrnn as character).
  def var ret as character.
  run find_rnn(vrnn).
  ret = getfio().
  release rnn.
  release rnnu.
  return ret.
end function.


/* функция возвращает "АДРЕС" из rnn или rnnu по заданному РНН */
function getadr1 returns character (vrnn as character).
  def var ret as character.
  run find_rnn(vrnn).
  ret = getadr().
  release rnn.
  release rnnu.
  return ret.
end function.
