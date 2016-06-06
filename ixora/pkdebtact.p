/* pkdebtact.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Должники на контроле
 * RUN
      
 * CALLER
    pkdebt1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-14-6
 * AUTHOR
        01.02.2004 nadejda
 * CHANGES
        06.02.2004 suchkov Подцеплены справочники
        05.04.2004 tsoy    отменил редактировние даты и пользователя, автоматическое утановление статуса, расширил поле для примечаний
        12.04.2004 tsoy    изменил автоматическую установку статусов
        13/10/2005 madiyar добавилось поле balcom
        21/10/2005 madiyar небольшая оптимизация
        10/02/2006 madiyar добавилась обработка результата "leg" - передан в Юридический департамент
        24/02/2006 Natalya D. убрала отображение "ВЕС" - отображается только ПРИЧИНА (info[1]), реализовала возможность вызова справочника
                           причин(pkdbtinf). 
        27/02/2006 Natalya D. удалила лишнии строки(не существенно)
        16/05/2006 madiyar добавил статус "Z" - списанные за баланс
        02/08/2006 madiyar - добавил "КПро" (кол-во просрочек)
        20/11/2006 madiyar - добавил изменения в шаренной таблице t-pkdebt
        13/09/2007 madiyar - изменения в шаренной таблице t-debt
*/


{global.i}
{pk.i}

def input parameter p-lon as char no-undo.

def shared temp-table t-pkdebt like pkdebt
  field name      as   char
  field checkdt   as   date
  field yessendlt as   char
  field bal1      like lon.opnamt   /* основной долг */
  field bal2      like lon.opnamt   /* проценты      */
  field balpen    like lon.opnamt   /* штрафы        */
  field balcom    like lon.opnamt   /* комиссия за вед. счета */
  field bal3      like lon.opnamt   /* общая сумма задолженности */
  field balz1     like lon.opnamt   /* списанный ОД */
  field balz2     like lon.opnamt   /* списанные % */
  field balzpen   like lon.opnamt   /* списанные штрафы */
  field bal4      like lon.opnamt   /*4уровень*/
  field bal5      like lon.opnamt   /*5уровень*/
  field balmon    like lon.opnamt
  field aaabal    like lon.opnamt
  field crc       like lon.crc
  field lastlt    as   char
  field lastltdt  as   date
  field roll      as   integer
  field stype     as   char
  field duedt     like lon.duedt
  field lgrfdt    as date
  field expdt     as date
  field eday      as integer
  field prkol     as integer.


def shared temp-table t-debt like t-pkdebt
  field days_prc as integer.

define variable s_rowid as rowid no-undo.
def var v-ans as logical no-undo.
def var v-tim as char no-undo.

find first t-pkdebt where t-pkdebt.lon = p-lon no-lock.
if not avail  t-pkdebt then return.

{jabrw.i
&start     = "def var v-info as char view-as editor inner-chars 40 INNER-LINES 3.
              def frame fr v-info.
              on help of pkdebtdat.action in frame f-dat do:
                run uni_book ('pkdbtact','',output pkdebtdat.action).
                display pkdebtdat.action with frame f-dat.
              end.
              on help of pkdebtdat.result in frame f-dat do:
                run uni_book ('pkdbtres','',output pkdebtdat.result).
                display pkdebtdat.result with frame f-dat.
              end.
              on help of pkdebtdat.info[1] in frame f-infos do:         
                run uni_book ('pkdbtinf','',output pkdebtdat.info[2]).
                find first bookcod where bookcod.bookcod = 'pkdbtinf' and bookcod.code = pkdebtdat.info[2] no-lock no-error.
                if avail pkdebtdat then pkdebtdat.info[1] = bookcod.name.  
                display pkdebtdat.info[1] with frame f-infos.
              end."

&head      = "pkdebtdat"
&headkey   = "rdt"
&index     = "lonrdt"

&formname  = "pkdebtact"
&framename = "f-dat"
&frameparm = " "
&where     = " pkdebtdat.bank = s-ourbank and pkdebtdat.lon = p-lon "

&addcon    = "true"
&deletecon = "true"
&highlight = " pkdebtdat.rdt v-tim pkdebtdat.rwho pkdebtdat.action "
&postcreate = " pkdebtdat.bank = s-ourbank. pkdebtdat.credtype = t-pkdebt.credtype.
                pkdebtdat.ln = t-pkdebt.ln. pkdebtdat.lon = p-lon.
                pkdebtdat.rdt = g-today. pkdebtdat.rtim = time. pkdebtdat.rwho = g-ofc. "

&prechoose = " hide message. message 'F4 - выход'. "

&predisplay = " v-tim = entry(1, string(pkdebtdat.rtim, 'HH:MM:SS'), ':') + ':' + entry(2, string(pkdebtdat.rtim, 'HH:MM:SS'), ':')."

&display   = "pkdebtdat.rdt v-tim pkdebtdat.rwho pkdebtdat.action pkdebtdat.result pkdebtdat.checkdt pkdebtdat.info[3]"
&postdisplay = " "

&update = " "

&postupdate   = " update pkdebtdat.rdt with frame f-dat.
                  update pkdebtdat.action with frame f-dat.
                  find bookcod where bookcod.bookcod = 'pkdbtact' and bookcod.code = pkdebtdat.action no-lock.
                  pkdebtdat.info[2] = bookcod.info[1].
                  /*displ pkdebtdat.info[2] with frame f-dat.*/
                  update pkdebtdat.result pkdebtdat.checkdt with frame f-dat.
                  update pkdebtdat.info[1] with scrollable frame f-infos. hide frame f-infos no-pause.
                  /*update pkdebtdat.info[3] with frame f-dat.*/
                  if length (pkdebtdat.info[1])  > 0 then  pkdebtdat.info[3] = ""*"".
                  if length (pkdebtdat.info[1])  = 0 then  pkdebtdat.info[3] = """".

                  t-pkdebt.checkdt = pkdebtdat.checkdt.
 
                  next upper. "
&postkey   = " "

&end = " if t-pkdebt.balz1 + t-pkdebt.balz2 + t-pkdebt.balzpen > 0 then t-pkdebt.sts = 'Z'.
         else do:
              find first pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = p-lon and pkdebtdat.rdt >= (g-today - t-pkdebt.days) use-index lonrdt no-lock no-error.
              if avail pkdebtdat then t-pkdebt.sts = 'K'. else t-pkdebt.sts = 'N'.
              find last pkdebtdat where pkdebtdat.bank = s-ourbank and pkdebtdat.lon = p-lon and pkdebtdat.rdt >= (g-today - t-pkdebt.days) and
                                  (pkdebtdat.result = 'part' or pkdebtdat.result = 'secu' or pkdebtdat.result = 'leg') use-index lonrdt no-lock no-error.
              if avail pkdebtdat then do:
                 if pkdebtdat.result = 'part' then t-pkdebt.sts = 'K,P'.
                 else if pkdebtdat.result = 'secu' then t-pkdebt.sts = 'K,S'.
                 else if pkdebtdat.result = 'leg' then t-pkdebt.sts = 'K,L'.
              end.
         end.
hide message no-pause. hide frame f-dat no-pause."
}