/* r-cas2.p
 * MODULE
        Обороты по счетам ГК 100100
 * DESCRIPTION
        Обороты по счетам ГК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
      22/05/07 marinav
 * CHANGES
      17/03/2009 madiyar - если не находится СП, то привязывается к ЦО филиала
*/

def  shared var v-from as date .
def  shared var v-to as date .
def  shared var v-glacc as int format ">>>>>>".
def  shared var s-ourbank as char.


def input parameter v-bank as char.

find txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error .
if s-ourbank ne 'TXB00' and s-ourbank ne trim(txb.sysc.chval) then return.


def var v-dat as date.

def shared temp-table t-cas
    field jl as int
    field jdt as date
    field des as char
    field dam as deci
    field cam as deci
    field ofc as char
    field point as char
    field crc as inte
    index pointcrc point crc jl.

    find first txb.cmp.

    find txb.gl where txb.gl.gl = v-glacc no-lock no-error.

    do v-dat = v-from to v-to:
      for each txb.jl no-lock where txb.jl.jdt = v-dat and txb.jl.gl = v-glacc use-index jdt :
          find last txb.ofchis where txb.ofchis.ofc = txb.jl.who and txb.ofchis.regdt le txb.jl.jdt no-lock no-error.
          find last txb.ppoint where txb.ppoint.depart = txb.ofchis.depart no-lock no-error.
          if not avail txb.ppoint then find first txb.ppoint where txb.ppoint.depart = 1 no-lock no-error.
          create t-cas.
          assign t-cas.jl  = txb.jl.jh
                 t-cas.jdt = txb.jl.jdt
                 t-cas.des = txb.jl.rem[1]
                 t-cas.dam = txb.jl.dam
                 t-cas.cam = txb.jl.cam
                 t-cas.ofc = txb.jl.who
                 t-cas.point = entry(1, txb.cmp.addr[1]) + " " + txb.ppoint.name
                 t-cas.crc = txb.jl.crc.

      end.
    end. /*v-dat*/

