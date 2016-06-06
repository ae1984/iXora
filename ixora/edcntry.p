/* edcntry.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Редактирование справочника стран с буквенными кодами и наименованиями
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-16
 * AUTHOR
        26.08.2003 nadejda
 * CHANGES
	30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i}
{comm-txb.i}

def var v-title as char.
def var v-codif as char init "iso3166".
def var v-bank as char.
def var v-centrofis as logical.
def var v-ans as logical.
def var v-vidsort as char.

define variable s_rowid as rowid.

def temp-table t-country 
  field code as char
  field rname as char
  field ename as char
  field sort as char
  index main is primary sort.

/*
find codific where codific.codfr = v-codif no-lock no-error.
v-title = codific.name.
*/

v-bank = comm-txb ().

v-centrofis = (v-bank = "TXB00").

v-title = "МЕЖДУНАРОДНЫЕ КОДЫ СТРАН (ТЕРРИТОРИЙ)".


for each codfr where codfr.codfr = v-codif and codfr.code <> "msc" no-lock:
  create t-country.
  assign t-country.code = codfr.code
         t-country.rname = trim(codfr.name[2])
         t-country.ename = trim(codfr.name[1])
         t-country.sort = caps(trim(codfr.name[2])) + codfr.code.
end.


{jabrw.i 
&start     = "displ v-title format 'x(50)' at 15 with row 4 no-box no-label frame f-header."
&head      = "t-country"
&headkey   = "code"
&index     = "main"

&formname  = "edcntry"
&framename = "f-ed"
&where     = " true "

&addcon    = " v-centrofis "
&deletecon = " v-centrofis "
&postcreate = " "
&prechoose = "displ '<F4>- выход, <INS>- вставка, <F10>- удалить, <P>- печать, <C,R,E>- сортировка' 
  with centered row 22 no-box frame f-footer."

&postdisplay = " "
&display   = " t-country.code t-country.rname t-country.ename "
&highlight = " t-country.code  "
&update   = " t-country.code when v-centrofis t-country.rname when v-centrofis t-country.ename when v-centrofis "
&postupdate = " if not v-centrofis then message ' Редактирование разрешено только для головного банка!'. "

&postkey   = "else if keyfunction(lastkey) = 'P' then do:
                         s_rowid = rowid(t-country).
                         output to cntrydata.img .
                         for each t-country :
                             display t-country.code t-country.rname t-country.ename.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('cntrydata.img').
                         find t-country where rowid(t-country) = s_rowid no-lock.
                      end. 
              else
              if keyfunction(lastkey) = 'c' or keyfunction(lastkey) = 'с' or 
                 keyfunction(lastkey) = 'r' or keyfunction(lastkey) = 'к' or 
                 keyfunction(lastkey) = 'e' or keyfunction(lastkey) = 'у' then do:
                 /* сортировки списка */ 
                v-vidsort = keyfunction(lastkey). 
                run addnastr(v-vidsort).
                /* надо перерисовать */ 
                clin = 0. curflag = 1. next upper. 
              end.
                      "

&end = "hide frame f-ed. hide frame f-header. hide frame f-footer."
}
hide message.


/* записать измененные данные */
for each t-country :
  find codfr where codfr.codfr = v-codif and codfr.code = t-country.code no-lock no-error.

  if not avail codfr then do transaction:
    create codfr.
    assign codfr.codfr = v-codif
           codfr.level = 1
           codfr.code = t-country.code.
  end.

  if codfr.name[1] <> t-country.ename or 
     codfr.name[2] <> t-country.rname or 
     codfr.tree-node <> v-codif + caps(trim(t-country.rname)) + caps(trim(t-country.ename)) then do:
    find current codfr exclusive-lock.

    assign codfr.name[1] = trim(t-country.ename)
           codfr.name[2] = trim(t-country.rname)
           codfr.tree-node = v-codif + caps(trim(t-country.rname)) + caps(trim(t-country.ename)).
  end.
  release codfr.
end.


/* удалить удаленные записи */
for each codfr where codfr.codfr = v-codif and codfr.code <> "msc" and 
    not can-find (t-country where t-country.code = codfr.code) exclusive-lock:
  delete codfr.
end.


if v-centrofis then do: 
  v-ans = yes.
  message skip " Синхронизировать справочник стран на филиалах с головным офисом?"
          skip(1) view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-ans.

  if v-ans then do:
    /* переписать изменения на филиалы */
    if connected ("ast") then disconnect "ast".
    for each comm.txb where comm.txb.consolid and comm.txb.is_branch no-lock:
      connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + comm.txb.login + " -P " + comm.txb.password). 
      run edcntryfil.
      disconnect "ast".
    end.
    if connected ("ast") then disconnect "ast".
  end.
end.


procedure addnastr.
  def input parameter p-vidsort as char.

  for each t-country :
    case caps(p-vidsort):
      when "C" or when "С" then do: t-country.sort = t-country.code. end.
      when "R" or when "К" then do: t-country.sort = caps(t-country.rname) + t-country.code. end.
      when "E" or when "У" then do: t-country.sort = caps(t-country.ename) + t-country.code. end.
    end case.
  end.
end procedure.

