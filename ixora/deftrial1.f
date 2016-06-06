/* deftrial1.f
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

{proghead.i " Report Trial balance    "}
def var dcnt as int format "zzzz9" label "ТРАН.".
def var ccnt as int format "zzzz9" label "ТРАН.".
def var tdcnt as int format "zzzz9" label "ТРАН.".
def var tccnt as int format "zzzz9" label "ТРАН.".
def var dr like jl.dam label "ДЕБЕТ ".
def var cr like jl.cam label "КРЕДИТ ".
def var vcif like cif.cif.
def var vpost as log.
def var grbook as int format "zzzzz9" label "Г/К".
def var vasof as date label "ЗА ".
def var vglbal like glbal.bal.
def var vsubbal like glbal.bal.
/*
{mainhead.i}*/
def var titl as char format "x(132)".
def temp-table gll field gllist as char format "x(10)".
def var i as int.
def var tt as cha.
def var v-gll as char format "x(10)".
def var v-name like gl.des init "".
def var vgl like pglbal.gl.
def var v-sysc like sysc.chval.
/*def var r-day as date label "DATUMS".*/
def temp-table tbal
             field point like point.point
             field npoint as char format "x(30)"
             field gl like jl.gl
             field crc like jl.crc
             field dam like jl.dam
             field cam like jl.cam.
def var n-point as char format "x(30)".
def var v-point like point.point.
def var pvglbal like glbal.bal.
def var pvsubbal like glbal.bal.
