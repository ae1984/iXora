/* r-trx.p
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
       07.04.04 sasco вывод menu-prt
*/

/*r-trx.p
  отчет о тразакциях за день
  программа записывает в файл дебет и кредит проводки в одну строку
  19.12.2000 */

define buffer    c_jl        for jl.
define variable  dtFirst     as date      label " Начало ".
define variable  dtSecond    as date      label " Конец  ".
define variable  strUndefTrz as character format "x(500)".

{mainhead.i}
{gl-utils.i}

dtFirst  = g-today.
dtSecond = g-today.

display dtFirst
        dtSecond
        with row 8 centered frame frmNew title " Укажите период: ".

update dtFirst
       validate(dtFirst <= g-today,"За завтра невозможно получить отчет !")
              with frame frmNew.
                            
update dtSecond validate(dtSecond >= dtFirst and dtSecond <= g-today,
       "Должно быть:Начало <= Конец <= Сегодня")
               with frame frmNew.

if dtSecond >= dtFirst 
   then do:
    output to "1.txt".
    put unformatted "Транз. | Дб Г/К | Дб Счет   | Кр Г/К | Кр Сч     |           Сумма "
    "|Вал| Примечание                          | Офицер   | Дата" skip(2).

    for each jl where jl.jdt >= dtFirst 
                  and jl.jdt <= dtSecond
                  and jl.dc = "D" 
                  no-lock by jl.crc by jl.jh:
        find first c_jl where c_jl.jh = jl.jh 
                          and c_jl.dc = "C" 
                          and c_jl.crc = jl.crc 
                          and c_jl.cam = jl.dam
                          no-lock no-error.
        if available c_jl then
    
           put unformatted jl.jh " | " jl.gl format ">>>>>>" " | " jl.acc format "x(9)" 
               " | " c_jl.gl format ">>>>>>" " | "
               c_jl.acc format "x(9)" " | " XLS-NUMBER (jl.dam) format "x(15)" " | " jl.crc " | " 
               jl.rem[1] format "x(35)" " | " jl.who format "x(8)" " | " jl.jdt skip.

        else strUndefTrz = strUndefTrz + string(jl.jh) + ";" 
                          + XLS-NUMBER(jl.dam) + chr(10).
    end.
    if strUndefTrz <> "" then do:
       put "Неизвестные проводки: " chr(13).
       put strUndefTrz.
    end.
    output close.
/*    message "Файл 1.txt сохранен в вашей FTP-директории". */
      run menu-prt ("1.txt").
  end.
  else message "Дата окончания должна быть больше даты начала периода".
return.  
