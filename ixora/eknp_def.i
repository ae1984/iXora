/* eknp_def.i
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
        11.06.2004 nadejda - все поменяла в связи с изменением отчета по постановлению НБ РК
                             теперь берутся только корсчета (ГК 1052), БИК можно не писать при некоторых условиях,
                             все в тенге
                             и в конце должна отражаться курсовая разница - для нее отдельная таблица

        01.09.2010 marinav - изменение БИКа
*/

{eknp_gl.i}

define {1} shared var v-dtb as date.
define {1} shared var v-dte as date.
def var v-ourbic as char init "MEOKKZKA".

find sysc where sysc.sysc = 'clecod'.
v-ourbic = trim(sysc.chval).


def {1} shared temp-table t-eknp
    field jdt like jl.jdt
    field sub as char
    field acc as char
    field sbank as char format "x(12)"
    field sbanksend as char format "x(12)"
    field rbank as char format "x(12)"
    field rbanksend as char format "x(12)"
    field bank2 as char format "x(9)"
    field bank2cnt as char format "x(9)"
    field cbank as char format "x(9)"
    field crc like crc.crc
    field crcode as char format "x(3)" label "Вал"
    field jh1 like jl.jh
    field jh2 like jl.jh
    field gl like jl.gl column-label "ГК" label "ГК" 
    field dam like jl.dam column-label "Дебет" label "Дебет"
    field cam like jl.cam column-label "Кредит" label "Кредит"
    field sumkzt as deci format "zzz,zzz,zzz,zz9.99" 
    field s_locat as int format ">" column-label "" label ""
    field s_secek as int format ">" column-label "" label ""
    field r_locat as int format ">" column-label "" label ""
    field r_secek as int format ">" column-label "" label ""
    field knp as char format "999" column-label "КНП" label "КНП"
    field cnt as char format "x(2)" column-label "Страна" label "Страна"
    field cntsend as char format "x(2)" column-label "Страна" label "Страна"
    field cntcbank as char format "x(2)"
    field rem like jl.rem[1]
    field who like jl.who
    field ptype as int format "99"
    field cbnk2cbnk as char
    field errors as char format "x(30)"
    index main jdt jh1.

def {1} shared temp-table t-corracc
  field gl like gl.gl
  field acc like dfb.dfb
  field crc like crc.crc
  field sum as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field balb as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field bale as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field balbkzt as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field balekzt as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field balcurs as deci format "->>>,>>>,>>>,>>>,>>9.99" 
  field sbanksend as char format "x(12)"
  field rbanksend as char format "x(12)"
  field bank2 as char format "x(9)"
  field s_locat as int format ">" column-label "" label ""
  field s_secek as int format ">" column-label "" label ""
  field r_locat as int format ">" column-label "" label ""
  field r_secek as int format ">" column-label "" label ""
  field knp as int format ">>>" column-label "КНП" label "КНП"
  field cnt as char format "x(2)" column-label "Страна" label "Страна"
  field cntsend as char format "x(2)" column-label "Страна" label "Страна"
  field kz as logical
  field ptype as int format "99"
  index acc gl crc acc.


/*
define {1} shared temp-table m_table
  field  i_src   as char format "x(2)" label ""
  field  s_mfoacc as char format "x(9)" label "Отправитель"
  field  r_mfoacc as char format "x(9)" label "Получатель"
  field  p_plt   as char format "x(2)" label ""
  field  s_gl as char format "x(9)" 
  field  r_gl as char format "x(9)" 
  field  s_locat as char format "x(1)" label ""  
  field  s_secek like s_locat
  field  r_locat like s_locat
  field  r_secek like s_locat 
  field  spnpl   like bank.trxcods.code format "x(3)"  label "КНП"
  field  amt     like bank.jl.dam
  field  crc     like bank.crc.crc
  field  jh      like bank.jl.jh
  field  staat   as char format "x(2)" label "Страна"
.
*/
