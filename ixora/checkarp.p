/* checkarp.p
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
        06.08.2004 saltanat - Включила проверку на арп - касса счет, при вып-и условия проверка контроля 2.7 отменяется
        04.02.2005 suchkov, valery - Поправили алгоритм проверки исключений по контролю
*/

/*---------------------------------------*/
/* контроль проводок по заданным счетам  */
/* 19/07/2002, sasco                     */
/*---------------------------------------*/

define input parameter v-doc as char format 'x(12)'. /* номер документа - RMZ, JOU */

define shared var g-ofc as char. 

define var valdat as date.
define var summa as decimal.
define var acnt as char.
define var m_sub as char.
define var res as char init 'yes'. 

/* - - - - - - - - - - - - - - - - - - */

 find sysc where sysc.sysc = "ourbnk" no-lock no-error.

/* - - - - - - - - - - - - - - - - - - */

 m_sub = caps (substr (v-doc, 1, 3)).
 /* найдем нужный нам платеж               */
 /* и проставим дату валютирования + сумму */
 case m_sub:

     when 'RMZ' then do:
                        find remtrz where remtrz.remtrz = v-doc
                                          no-lock no-error.
                        valdat = remtrz.valdt1.
                        summa = remtrz.amt.
                        acnt = remtrz.dracc.
                    end.
     when 'JOU' then do:
                        find joudoc where joudoc.docnum = v-doc no-lock no-error.
                        valdat = joudoc.whn.
                        summa = joudoc.dramt.
                        acnt = joudoc.dracc.

                        /* 06.08.2004 saltanat - проверяем на кассовый счет */
                        if joudoc.dracctype = "4" then do:
                        find first arpcon where arpcon.arp = joudoc.dracc and arpcon.sub = "jou" and arpcon.txb = 'TXB00' no-lock no-error.
                        if avail arpcon then 
                        if joudoc.cracctype = "1" then do:
                           return 'yes'.
                        end.
                        end.
                    end.

     otherwise return 'yes'.

 end case.


 /* найдем настройку счета для контроля */
 find arpcon where arpcon.arp = acnt and arpcon.txb = sysc.chval and arpcon.sub = m_sub no-lock no-error.
 if avail arpcon then do:

         /* проверить на юзера           */
         /* нет в списке - пеняй на себя */
         if LOOKUP (g-ofc,arpcon.uids) = 0 then
         do:

         /* найдем в истории, находится ли платеж на очереди для контроля */
         find cursts where cursts.sub = m_sub and cursts.acc = v-doc and
                           cursts.sts = arpcon.new-sts use-index subacc no-lock no-error.
         if avail cursts then return 'con'. /* надо подождать контроль! */

         /* найдем в истории, был ли уже контроль (то есть sts = arpcon.new-sts) */
         find substs where substs.sub = m_sub and substs.acc = v-doc and
                           substs.sts = arpcon.new-sts no-lock no-error.
         if avail substs then return 'yes'. /* типа уже ничего не надо */


           /* если надо проверять сумму проводки */
           if arpcon.checktrx then do:

            if (summa >= arpcon.maxtrx) then
            do:
               message "Нельзя сделать проводку по счету " + acnt +
                       "~n на сумму свыше" arpcon.maxtrx view-as alert-box.
               return 'no'.
            end.

               /* если месяц даты счетчика меньше месяца документа...*/
               if (month(arpcon.date) < month(valdat)) or
                  /* или номер месяца больше, но год меньше ...*/
                  ((month(arpcon.date) > month(valdat)) and
                   (year(arpcon.date) < year(valdat))) then
                  do: /* обнулить счетчик */

                      for each arpcon where arpcon.arp = acnt and arpcon.txb = sysc.chval:
                          arpcon.date = valdat.
                          arpcon.curr = summa.
                          res = 'yes2'.
                      end.

                      find arpcon where arpcon.arp = acnt and
                                        arpcon.txb = sysc.chval and
                                        arpcon.sub = m_sub no-lock no-error.
               end.
               else /* как-бы тот же месяц, то есть идем на контроль!*/
               do:  /* проверить счетчик */
                  if (arpcon.max le (arpcon.curr + summa)) and arpcon.checkmax then do:
                    /* если лимит оказался меньше новой суммы... */
                     message "Нельзя сделать проводку по " + arpcon.arp +
                              "~n иначе достигнут лимит по сумме за месяц" view-as alert-box.
                     res = 'no'.
                  end.
                  else do:
                      /* иначе - приплюсовать*/
                      for each arpcon where arpcon.arp = acnt and arpcon.txb = sysc.chval:
                          arpcon.curr = arpcon.curr + summa.
                          res = 'yes2'.
                      end.

                      find arpcon where arpcon.arp = acnt and
                                        arpcon.txb = sysc.chval and
                                        arpcon.sub = m_sub no-lock no-error.
                  end.
               end. /* month */

              end. /* checkTRX */
              else res = "yes2".

            end. /* LOOKUP */
            else res = 'yes'.

   end. /* avail ARPCON */
   else res = 'yes'.

/* если прошел контроль и надо изменить статус -> new-sts */
if res = 'yes2' then do:
                        run chgsts (m_sub, v-doc, arpcon.new-sts). 
                        res = 'con'.
                     end.

return res.

/* возвращает con - на очереди для контроля, не трогать!
              yes - может топать дальше
              no  - не прошел проверку, никуда не пустим
*/
