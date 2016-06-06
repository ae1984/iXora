/* amt_level.p
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
        25/11/03 nataly был добавлен новый subledger SCU
        18/04/06 nataly добавлена обработка subledger TSF
        25/09/2008 galina - счет 20-тизначный 
        26/09/2008 galina - явно указала ширину фреймов
        12.01.2009 galina - добавила закрытие фрейма f_bal, т.к. при просмотре остатков на уровнях для ссудных счетов он не закрывался
*/

/***  amt_level.p  ***/


define input parameter Psub as character format "x(3)".
define input parameter Pacc as character format "x(20)".
  
  /*
define var Psub as character format "x(3)".
define var Pacc as character format "x(10)".
    */

define temp-table ttleve
    field t_dam like trxbal.dam
    field t_cam like trxbal.cam
    field t_amt like trxbal.cam
    field t_crc like crc.code
    field t_lev like trxbal.level
    field t_glr like gl.gl
    index t_ind is unique t_crc t_lev.

define query q_bal for ttleve scrolling.
define browse b_bal query q_bal display 
    ttleve.t_crc label "Вал." 
    ttleve.t_lev label "Ур." format "zzz9"
    ttleve.t_dam label "Дебет" format "zzzzzzz,zzz,zzz,zz9.99"
    ttleve.t_cam label "Кредит" format "zzzzzzz,zzz,zzz,zz9.99"
    ttleve.t_amt label "Остаток" format "zzzzzzz,zzz,zzz,zz9.99-"
    with 16 down.
define frame f_bal b_bal with width 86 side-labels row 5 column 13 no-box overlay.


define frame f_account
    Pacc label " Номер счета"
    crc.crc label "Валюта счета"
    crc.des no-label skip
    gl.gl label " Глав.книга"
    gl.des no-label format "x(50)"
    with width 85 side-labels row 1 centered overlay.
 
define frame f_level
    trxsublv.des label  "    Наим. уровня" skip
    gl.gl        label  "    Гл.кн.уровня"
    gl.des       no-label format "x(50)"
    space(7)
    with width 85 row 25 centered overlay side-labels.


     if Psub eq "fun" then do: {amt_level.i "fun" Pacc Psub}.  end.
else if Psub eq "scu" then do: {amt_level.i "scu" Pacc Psub}.  end.
else if Psub eq "tsf" then do: {amt_level.i "tsf" Pacc Psub}.  end.
else if Psub eq "cif" then do: {amt_level.i "aaa" Pacc Psub}.  end. 
else if Psub eq "lon" then do: {amt_level.i "lon" Pacc Psub}.  end.
else if Psub eq "arp" then do: {amt_level.i "arp" Pacc Psub}.  end.
else if Psub eq "ock" then do: {amt_level.i "ock" Pacc Psub}.  end.
else if Psub eq "dfb" then do: {amt_level.i "dfb" Pacc Psub}.  end.
else if Psub eq "ast" then do: {amt_level.i "ast" Pacc Psub}.  end.
else if Psub eq "eps" then do: {amt_level.i "eps" Pacc Psub}.  end.
else do:
    message  substitute ("&1 - Тип счета не описан", Psub).
    return.
end.

on "end-error" of frame f_bal do:
 hide frame f_level.
end.
                                      
wait-for window-close of current-window.
