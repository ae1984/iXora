/* h-rmz8iall.p
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
        tsoy 31/12/99 pragma
 * CHANGES
        18.12.2005 tsoy     - добавил время создания платежа.
*/

{global.i}
{lgps.i }

def shared var s-remtrz like que.remtrz .

def var h as int .
def var v-ofc like ofc.ofc.
def var choice as integer format '9' init 1.
def temp-table w-remtrz
    field  remtrz  like que.remtrz 
    field  ref     like remtrz.ref 
    field  payment like remtrz.payment 
    field  name    like cif.name
    field  crc     like remtrz.tcrc 
    field  source  like remtrz.source
    field  ptype   like remtrz.ptype 
    field  rdt     like remtrz.rdt 
    field  valdt1  like remtrz.valdt1 
    field  valdt2  like remtrz.valdt2
    field  sbank   like remtrz.sbank 
    field  rbank   like remtrz.rbank 
    field  pid     like que.pid
    field  con     like que.con
    field  who     like g-ofc
    field  urgency as char
    index idx_tmp is primary urgency who.    
                             

h = 12 .
v-ofc = userid('bank').


message
  "1)По одному менеджеру 2)Все  "
    update choice .

    for each remtrz where remtrz.rdt >= g-today - 3
                          and remtrz.source = 'IBH'
                          use-index rdt no-lock .

              if remtrz.rdt <> g-today and remtrz.valdt1 <> g-today and remtrz.valdt2 <> g-today then next.
              
              find ib.doc where ib.doc.remtrz = remtrz.remtrz no-lock no-error.

              if not avail ib.doc or ib.doc.type <> 5 then next.

              find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
              
              find cif where cif.cif = aaa.cif no-lock no-error.

              find que where que.remtrz = remtrz.remtrz no-lock no-error.

              if (choice = 1 and remtrz.tcrc = 1 and (substr(cif.fname,1,8)) = v-ofc) or
                 (choice = 2 and remtrz.tcrc = 1)   then do:
                 create w-remtrz.                 
                  w-remtrz.remtrz  =  remtrz.remtrz.
                  w-remtrz.ref     =  remtrz.ref.
                  w-remtrz.name    =  trim (cif.prefix + " " + trim(cif.name)). 
                  w-remtrz.payment =  remtrz.payment.
                  w-remtrz.crc     =  remtrz.tcrc.
                  w-remtrz.source  =  remtrz.source.
                  w-remtrz.ptype   =  remtrz.ptype.
                  w-remtrz.rdt     =  remtrz.rdt.
                  w-remtrz.valdt1  =  remtrz.valdt1.
                  w-remtrz.valdt2  =  remtrz.valdt2.
                  w-remtrz.sbank   =  remtrz.sbank.
                  w-remtrz.rbank   =  remtrz.rbank .
                  w-remtrz.who     =  cif.fname.
                  w-remtrz.pid     =  que.pid.
                  w-remtrz.con     =  que.con.

                  if avail ib.doc and ib.doc.urgency = "U"  then do:
                      w-remtrz.urgency = "*".
                  end.
               end.
     end.
     {browpnp.i
      &h = "h"
      &where = "w-remtrz.source eq 'IBH' "   
      &frame-phrase = "row 1 centered scroll 1 h down"   
      &predisp =  " display
                    w-remtrz.source column-label ""Источник""
                    w-remtrz.ptype column-label ""Тип""
                    w-remtrz.rdt column-label ""Рег.дата""
                    w-remtrz.valdt1 column-label ""1Дата""
                    w-remtrz.valdt2 column-label ""2Дата""
                    w-remtrz.sbank column-label ""БанкО""
                    w-remtrz.rbank column-label ""БанкП""
                    with row 17.
                    pause 0 .
                    display
                    w-remtrz.pid column-label ""Код""
                    w-remtrz.con column-label ""Сост.""
                    with row 17.
                    pause 0. " 
      &seldisp = " w-remtrz.remtrz "
      &file = " w-remtrz " 
      &disp = " w-remtrz.urgency column-label ""П"" format 'x(1)'
                w-remtrz.remtrz  column-label ""Платеж""
                w-remtrz.name column-label ""Клиент"" format 'x(30)' 
                w-remtrz.payment column-label ""СуммаК"" format 'zzz,zzz,zzz,zz9.99-'
                w-remtrz.crc column-label ""Вал"" 
                w-remtrz.who column-label ""Менеджер""              "  
      &addupd = " w-remtrz.remtrz "
      &upd    = "  "
      &addcon = " false "
      &updcon = " false "
      &delcon = " false "
      &retcon = " true "
      &enderr = " hide all.  "  
      &befret = " s-remtrz = w-remtrz.remtrz .
                  frame-value = w-remtrz.remtrz .
                  hide all. "  }    
        