/* rep_fh.p
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
        21/06/2004 dpuchkov
 * CHANGES
*/

define input parameter i as integer.
define input parameter d_date as date.
define input parameter d_date_fin as date.
define input parameter v-accstatus as char. /*4-счета доходов, 5-счета расходов*/

define shared var v-indexnumber as integer.

def shared stream m-out1.
def var v-filial_name as char.
def var v-beg_ost as char.
def var v-end_ost as char.
def var v-sumdam as decimal init 0.
def var v-sumcam as decimal init 0.
def buffer b-jl for txb.jl.

    if  i= 0 then v-filial_name = "ALMATY". else
    if  i= 1 then v-filial_name = "ASTANA". else
    if  i= 2 then v-filial_name = "URALSK". else
    if  i= 3 then v-filial_name = "ATYRAU". 

    for each txb.gl where txb.gl.whn >= d_date and txb.gl.whn <= d_date_fin and txb.gl.totlev = 1  no-lock:
       if  substring(string(txb.gl.gl), 1, 1) = v-accstatus then
       do:
         if (v-accstatus = "4" and v-indexnumber = 0) then
            put stream m-out1  '1. СЧЕТА ДОХОДОВ***************************************************************' skip.
         if (v-accstatus = "5" and v-indexnumber = 0) then do:
            put stream m-out1 ' '  skip.
            put stream m-out1  '2. СЧЕТА РАСХОДОВ***************************************************************' skip.
         end.
         v-indexnumber = v-indexnumber + 1.
         put stream m-out1 unformatted  
                           '# 'string(v-indexnumber)  ' TEXAKABANK 'v-filial_name ' ' txb.gl.whn
                           ' 'string(txb.gl.gl) ''  
                           ' 'trim(txb.gl.des) skip.
       end.
    end.
