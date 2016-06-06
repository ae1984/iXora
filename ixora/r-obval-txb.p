/* r-obval.p
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
 * BASES
        BANK TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
      18/11/03 nataly добавлена проверка на счета ГК 100200, 100300
      28/02/06 nataly  поменяла  условие по joudoc.whn = jl.jdt
      23.08.06 u00124 оптимизация
      07/05/08 marinav - изменен расчет курсов
      28/05/10 id00363 - добавил возможность консолидации
      29.03.2012 aigul - добавила ГК 100500
*/

def shared var fdate as date no-undo.
def shared var tdate as date no-undo.

def shared temp-table temp
    field    dc    as    char format "x(1)"
    field    debv  like  txb.joudoc.dramt format "zzzz,zzz,zz9.99"
    field    credv like  txb.joudoc.dramt format "zzzz,zzz,zz9.99"
    field    crc   like  txb.crc.crc
    field    rate  like  txb.joudoc.srate format "zzz9.99"
    field    jh    like txb.jl.jh
    field    gl    like txb.jl.gl
    index main is primary crc dc rate credv debv.

def  shared temp-table temp1
    field rate like txb.joudoc.srate format "zzz9.99"
    field amt  like txb.joudoc.dramt
    field jh as int
    field dc as char.

def  shared temp-table temp2
    field rate  like txb.joudoc.srate format "zzz9.99"
    field amt   like txb.joudoc.dramt
    field jh as int
    field dc as char.

def shared var  v-amt as decimal.
def shared var v-rate like  txb.joudoc.srate format "zzzzzz9.99".
def shared var v-rate1 like  txb.joudoc.srate format "zzzzzz9.99".
def shared var v-amtrate as decimal.

def  shared stream   m-out.
def shared var i as integer no-undo.

def shared var v-gl1 like txb.jl.gl  init 100100 no-undo.
def shared var v-gl2 like txb.jl.gl  init 100200 no-undo.
def shared var v-gl3 like txb.jl.gl  init 100300 no-undo.
def shared var v-gl4 like txb.jl.gl  init 100500 no-undo.

def shared var v-dt as date no-undo.


do v-dt = fdate to tdate:
  hide message no-pause.
  message " Обработка " v-dt.
  for each txb.jl where txb.jl.jdt = v-dt and (txb.jl.gl = v-gl1  or txb.jl.gl = v-gl2 or txb.jl.gl = v-gl3 or txb.jl.gl = v-gl4) use-index jdt no-lock:
      if txb.jl.crc = 1 or substring(txb.jl.rem[1],1,5) <> "Обмен" then next.
      if jl.gl <> v-gl4 then do:
      if not ((txb.jl.dam <> 0 and txb.jl.ln = 1) or (txb.jl.cam <> 0 and txb.jl.ln = 4)) then next.
      end.
      find txb.joudoc where txb.joudoc.jh = txb.jl.jh and txb.joudoc.who = txb.jl.who and txb.joudoc.whn = txb.jl.jdt no-lock no-error.
      if avail txb.joudoc then do.
         create temp.
         if jl.dam <> 0 then do.
            temp.dc    = "d".
            temp.debv  = /*txb.joudoc.dramt*/ txb.jl.dam.
            temp.crc   = txb.jl.crc.
            temp.rate  = txb.joudoc.brate.
            temp.jh = txb.jl.jh.
            temp.gl = txb.jl.gl.
          end.
          else do.
            temp.dc    = "c".
            temp.credv = /*txb.joudoc.cramt*/ txb.jl.cam.
            temp.crc = txb.jl.crc.
            temp.rate = txb.joudoc.srate.
            temp.jh = txb.jl.jh.
            temp.gl = txb.jl.gl.
          end.
      end.
  end.
end.