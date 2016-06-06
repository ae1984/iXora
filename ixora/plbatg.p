/* plbatg.p
 * MODULE
        Платежные системы
 * DESCRIPTION
        Отчет об объемах и кол-ве получаемых и отправляемых  тенговых платежей в БВУ.
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
     27.09.2004 saltanat
 * BASES
        BANK COMM
 * CHANGES
     12.10.2004 saltanat - Просмотр архивных платежей тоже.
     30.11.2004 saltanat - Включены платежа где банк является корреспондентом.
     06.01.2005 saltanat - Выборка по головному банку.
     08.04.2005 saltanat - Изменила вывод данных отчета.
     04.05.2005 saltanat - Включила выборку по маршруту отправки.
     15.08.2006 u00600   - оптимизация
     07.09.2010 marinav-  в отчет добавила филиалы
     18.05.2011 ruslan  - добавил разбивку по юр и физ лицам, добавил итого и всего, Собственные операции банка
     25/04/2012 evseev  - rebranding. Название банка из sysc.
     27/04/2012 evseev  - повтор

*/
{mainhead.i}
{nbankBik.i}

def var v-dtb  as date.
def var v-dte  as date.
def var v-bank as char.
def var v-mfo  as char.
def var t-s1   as deci format "-zzz,zzz,zzz,zzz,zz9.99" .
def var t-s2   as deci format "-zzz,zzz,zzz,zzz,zz9.99" .
def var v-cbank as char.
def var colcount as integer init 1.
def var i as inte.
def var usrnm as char.
def var path as char.
def var v-prz as char no-undo.


def temp-table t-plat
    field mfo   as char
    field bank  as char
    field ptype as inte /* 6 - исходящий , 7 - входящий */
    field cover as inte /* 1 - клиринг, 2 - гросс */
    field vx-kol-clr  as inte format 'zzzzzzzzzzzz9'    init 0
    field vx-obm-clr  as deci format 'zzzzzzzzzzzz9,99' init 0
    field isx-kol-clr as inte format 'zzzzzzzzzzzz9'    init 0
    field isx-obm-clr as deci format 'zzzzzzzzzzzz9,99' init 0
    field vx-kol-gro  as inte format 'zzzzzzzzzzzz9'    init 0
    field vx-obm-gro  as deci format 'zzzzzzzzzzzz9,99' init 0
    field isx-kol-gro as inte format 'zzzzzzzzzzzz9'    init 0
    field isx-obm-gro as deci format 'zzzzzzzzzzzz9,99' init 0
    field vx-kol-pko  as inte format 'zzzzzzzzzzzz9'    init 0  /* pko /Прямые корр.отношения/ - remtrz.source = 'DIR' */
    field vx-obm-pko  as deci format 'zzzzzzzzzzzz9,99' init 0
    field isx-kol-pko as inte format 'zzzzzzzzzzzz9'    init 0
    field isx-obm-pko as deci format 'zzzzzzzzzzzz9,99' init 0
    field intpay as logical init false
    field intpay-kol  as inte format 'zzzzzzzzzzzz9'    init 0
    field intpay-obm  as deci format 'zzzzzzzzzzzz9,99' init 0
index id isx-kol-clr descending isx-kol-gro descending isx-kol-pko descending vx-kol-clr descending vx-kol-gro descending vx-kol-pko descending.

def button  btn1  label "Юридические лица" .
def button  btn2  label "Физические лица" .
def button  btn3  label "Выход" .

def frame   frame1
   skip(1) btn1 btn2 btn3 with centered title "Выберете вариант отчета:" row 5 .

  on choose of btn1,btn2,btn3 do:
   if self:label = "Юридические лица" then v-prz = '0,1,2,3,4,5,6,7,8'.
    else
    if self:label = "Физические лица" then v-prz= '9'.
    else v-prz = '3'.
   end.
   enable all with frame frame1.
    wait-for choose of btn1, btn2, btn3.
    if v-prz = '3' then return.
 hide  frame frame1.

define frame f-dt
   skip(1)
   v-dtb label '    Начало периода' format '99/99/9999' skip
   v-dte label '     Конец периода' format '99/99/9999' skip
   v-mfo label '          По банку' format 'x(20)' skip
   t-s1  label ' Минимальная сумма' skip
   t-s2  label 'Максимальная сумма' skip
   path  label 'Маршрут платежей  ' help 'C-Клиринг;G-Гросс;P-Прямые корр.отношения;*-По всем маршрутам'
         validate(path = 'C' or path = 'G' or path = 'P' or path = '*' ,'') skip(1)
   with centered side-label row 5 title "УКАЖИТЕ ДАННЫЕ ОТЧЕТА".

on help of v-mfo in frame f-dt do:
{itemlist.i
&file = "bankl"
&frame = "row 6 centered scroll 1 12 down overlay "
&where = " bankl.bank = bankl.cbank "
&flddisp = " bankl.bank label 'МФО' format 'x(20)'
                 bankl.name label 'Наименование' format 'x(50)'
               "
&chkey = "bank"
&chtype = "string"
&index  = "bank"
&end = "if keyfunction(lastkey) eq 'end-error' then return."
}
   v-mfo  = bankl.bank.
   v-bank = bankl.name.
   displ v-mfo with frame f-dt.
end.

v-dtb = g-today.
v-dte = g-today.
v-mfo = '*'.
t-s1 = 0 .
t-s2 = 999999999999999.99 .
path = '*'.

update v-dtb v-dte v-mfo t-s1 t-s2 path with frame f-dt.

if v-mfo = '*' then v-bank = 'По всем банкам'.
else do:
if v-bank = '' then do:
   find bankl where bankl.bank = v-mfo no-lock no-error.
   if avail bankl then v-bank = bankl.name.
end.
end.


/* ***** КЛИРИНГ ***** */
if v-mfo = '*' then do:

for each remtrz where remtrz.rdt >= v-dtb and remtrz.rdt <= v-dte no-lock use-index rdt .
  if remtrz.tcrc <> 1 then next.
   find sub-cod where sub-cod.sub = 'rmz' and sub-cod.acc = remtrz.remtrz and sub-cod.d-cod = 'eknp' no-lock no-error.
    if not avail sub-cod then do:
        next.
    end.

    if remtrz.amt < t-s1 or remtrz.amt > t-s2 then next.

    /* Банк Получатель - указанный банк */
    if (remtrz.ptype = '2' or remtrz.ptype = '6') and lookup(substr(sub-cod.rcode,2,1),v-prz) > 0 then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             v-cbank = ''.
             if remtrz.rbank ne '' then do:
                 find bankl where bankl.bank = remtrz.rbank no-lock no-error.
                 v-cbank = bankl.cbank.
             end.
             else do:
                 if remtrz.rcbank ne '' then do:
                 find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
                 v-cbank = bankl.cbank.
                 end.
                 else next.
             end.

             find t-plat where t-plat.mfo = bankl.cbank no-lock no-error.
             find bankl where bankl.bank = v-cbank no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
		assign t-plat.mfo  = bankl.bank
       		       t-plat.bank = bankl.name.
       	     end.

       		if remtrz.ptype = '2' then do:
                if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
       		end.
       		if remtrz.ptype = '6' then do:
                if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
       		end.
                /* CLIRING */
                if remtrz.cover = 1 then do:
                  t-plat.isx-obm-clr = t-plat.isx-obm-clr + remtrz.amt.
                  t-plat.isx-kol-clr = t-plat.isx-kol-clr + 1.
                end.
                /* GROSS */
                if remtrz.cover = 2 then do:
                  t-plat.isx-obm-gro = t-plat.isx-obm-gro + remtrz.amt.
                  t-plat.isx-kol-gro = t-plat.isx-kol-gro + 1.
                end.
          end.
       end.

    end.

    /*if remtrz.ptype = '6' then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             v-cbank = ''.
             if remtrz.rbank ne '' then do:
                 find bankl where bankl.bank = remtrz.rbank no-lock no-error.
                 v-cbank = bankl.cbank.
             end.
             else do:
                 if remtrz.rcbank ne '' then do:
                 find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
                 v-cbank = bankl.cbank.
                 end.
                 else next.
             end.

             find t-plat where t-plat.mfo = bankl.cbank no-lock no-error.
             find bankl where bankl.bank = v-cbank no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
		assign t-plat.mfo  = bankl.bank
       		       t-plat.bank = bankl.name.
             end.

       		if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
       		else do:*/
             /* CLIRING */
             /*if remtrz.cover = 1 then do:
                  t-plat.isx-obm-clr = t-plat.isx-obm-clr + remtrz.amt.
                  t-plat.isx-kol-clr = t-plat.isx-kol-clr + 1.
             end. */
             /* GROSS */
             /*if remtrz.cover = 2 then do:
                  t-plat.isx-obm-gro = t-plat.isx-obm-gro + remtrz.amt.
                  t-plat.isx-kol-gro = t-plat.isx-kol-gro + 1.
             end.
             end.
          end.
       end.
    end.*/

    /* Банк Отправитель - указанный банк */

    if (remtrz.ptype = '5' or remtrz.ptype = '7') and lookup(substr(sub-cod.rcode,2,1),v-prz) > 0 then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             v-cbank = ''.
             if remtrz.sbank ne '' then do:
                 find bankl where bankl.bank = remtrz.sbank no-lock no-error.
                 v-cbank = bankl.cbank.
             end.
             else do:
                 if remtrz.scbank ne '' then do:
                 find bankl where bankl.bank = remtrz.scbank no-lock no-error.
                 v-cbank = bankl.cbank.
                 end.
                 else next.
             end.

             find t-plat where t-plat.mfo = bankl.cbank no-lock no-error.
             find bankl where bankl.bank = v-cbank no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
		assign t-plat.mfo  = bankl.bank
       		       t-plat.bank = bankl.name.
       	     end.

	         if remtrz.ptype = '5' then do:
       		 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
       		 end.

                 if remtrz.ptype = '7' then do:
                 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
                 end.
       		 /* CLIRING */
                 if remtrz.cover = 1 then do:
                    t-plat.vx-obm-clr = t-plat.vx-obm-clr + remtrz.amt.
                    t-plat.vx-kol-clr = t-plat.vx-kol-clr + 1.
                 end.
                 /* GROSS */
                 if remtrz.cover = 2 then do:
                    t-plat.vx-obm-gro = t-plat.vx-obm-gro + remtrz.amt.
                    t-plat.vx-kol-gro = t-plat.vx-kol-gro + 1.
                 end.
          end.
       end.
    end.

    /*if remtrz.ptype = '7' then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             v-cbank = ''.
             if remtrz.sbank ne '' then do:
                 find bankl where bankl.bank = remtrz.sbank no-lock no-error.
                 v-cbank = bankl.cbank.
             end.
             else do:
                 if remtrz.scbank ne '' then do:
                 find bankl where bankl.bank = remtrz.scbank no-lock no-error.
                 v-cbank = bankl.cbank.
                 end.
                 else next.
             end.

             find t-plat where t-plat.mfo = bankl.cbank no-lock no-error.
             find bankl where bankl.bank = v-cbank no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
			    assign t-plat.mfo  = bankl.bank
       			       t-plat.bank = bankl.name.
       		 end.

       		 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
       		 else do: */
       		 /* CLIRING */
             /*if remtrz.cover = 1 then do:
                  t-plat.vx-obm-clr = t-plat.vx-obm-clr + remtrz.amt.
                  t-plat.vx-kol-clr = t-plat.vx-kol-clr + 1.
             end.*/
             /* GROSS */
             /*if remtrz.cover = 2 then do:
                  t-plat.vx-obm-gro = t-plat.vx-obm-gro + remtrz.amt.
                  t-plat.vx-kol-gro = t-plat.vx-kol-gro + 1.
             end.
             end.
          end.
       end.
    end.*/

    if ((upper(remtrz.bn[1]) matches("*" + v-nbank1 + "*") and not(upper(remtrz.ord) matches("*" + v-nbank1 + "*"))) or
       (upper(remtrz.ord) matches("" + v-nbank1 + "") and not(upper(remtrz.bn[1]) matches("*" + v-nbank1 + "*")))) and lookup(substr(sub-cod.rcode,2,1),v-prz) > 0 then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             v-cbank = ''.
             if remtrz.rbank ne '' then do:
                 find bankl where bankl.bank = remtrz.rbank no-lock no-error.
                 v-cbank = bankl.cbank.
             end.
             else do:
                 if remtrz.rcbank ne '' then do:
                     find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
                     v-cbank = bankl.cbank.
                 end.
                 else next.
             end.

             find t-plat where t-plat.mfo = bankl.cbank no-lock no-error.
             find bankl where bankl.bank = v-cbank no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
		        assign t-plat.mfo  = bankl.bank
       		           t-plat.bank = bankl.name
                       t-plat.intpay-kol = t-plat.intpay-kol + remtrz.amt
                       t-plat.intpay-obm = t-plat.intpay-obm + 1
                       t-plat.intpay = true.
             end.
          end.
       end.
    end.

end.

end. /* TXB00 */
else do:
for each remtrz where remtrz.rdt >= v-dtb and remtrz.rdt <= v-dte no-lock use-index rdt.
   if remtrz.tcrc <> 1 then next.
    if remtrz.amt < t-s1 or remtrz.amt > t-s2 then next.

    if not avail sub-cod then do:
        next.
    end.

    /* Банк Получатель - указанный банк */
    if (remtrz.ptype = '2' or remtrz.ptype = '6') and lookup(substr(sub-cod.rcode,2,1),v-prz) > 0 then do:
        v-cbank = ''.
        if remtrz.rbank ne '' then do:
           find bankl where bankl.bank = remtrz.rbank no-lock no-error.
           v-cbank = bankl.cbank.
        end.
        else do:
           if remtrz.rcbank ne '' then do:
               find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
               v-cbank = bankl.cbank.
           end.
           else next.
        end.

    if v-cbank = v-mfo then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             find t-plat where t-plat.mfo = v-mfo no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
			    assign t-plat.mfo  = v-mfo
       			       t-plat.bank = v-bank.
       		 end.

                if remtrz.ptype = '2' then do:
       		if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
       		end.
                if remtrz.ptype = '6' then do:
                if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
                end.
                /* CLIRING */
                if remtrz.cover = 1 then do:
                    t-plat.isx-obm-clr = t-plat.isx-obm-clr + remtrz.amt.
                    t-plat.isx-kol-clr = t-plat.isx-kol-clr + 1.
                end.
                /* GROSS */
                if remtrz.cover = 2 then do:
                    t-plat.isx-obm-gro = t-plat.isx-obm-gro + remtrz.amt.
                    t-plat.isx-kol-gro = t-plat.isx-kol-gro + 1.
                end.
         end.
       end.
    end.
    end.

    /*if remtrz.ptype = '6' then do:
    v-cbank = ''.
    if remtrz.rbank ne '' then do:
       find bankl where bankl.bank = remtrz.rbank no-lock no-error.
       v-cbank = bankl.cbank.
    end.
    else do:
       if remtrz.rcbank ne '' then do:
       find bankl where bankl.bank = remtrz.rcbank no-lock no-error.
       v-cbank = bankl.cbank.
       end.
       else next.
    end.

    if v-cbank = v-mfo then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             find t-plat where t-plat.mfo = v-mfo no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
			    assign t-plat.mfo  = v-mfo
       			       t-plat.bank = v-bank.
       		 end.

       		if remtrz.crgl = 105210 then do:
                  t-plat.isx-obm-pko = t-plat.isx-obm-pko + remtrz.amt.
                  t-plat.isx-kol-pko = t-plat.isx-kol-pko + 1.
       		end.
       		else do:*/
             /* CLIRING */
             /*if remtrz.cover = 1 then do:
                  t-plat.isx-obm-clr = t-plat.isx-obm-clr + remtrz.amt.
                  t-plat.isx-kol-clr = t-plat.isx-kol-clr + 1.
             end. */
             /* GROSS */
             /*if remtrz.cover = 2 then do:
                  t-plat.isx-obm-gro = t-plat.isx-obm-gro + remtrz.amt.
                  t-plat.isx-kol-gro = t-plat.isx-kol-gro + 1.
             end.
            end.
          end.
       end.
    end.
    end.*/
    /* Банк Отправитель - указанный банк */

    if (remtrz.ptype = '5' or remtrz.ptype = '7') and lookup(substr(sub-cod.rcode,2,1),v-prz) > 0 then do:
    v-cbank = ''.
    if remtrz.sbank ne '' then do:
       find bankl where bankl.bank = remtrz.sbank no-lock no-error.
       v-cbank = bankl.cbank.
    end.
    else do:
       if remtrz.scbank ne '' then do:
       find bankl where bankl.bank = remtrz.scbank no-lock no-error.
       v-cbank = bankl.cbank.
       end.
       else next.
    end.

    if v-cbank = v-mfo then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             find t-plat where t-plat.mfo = v-mfo no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
			    assign t-plat.mfo  = v-mfo
       			       t-plat.bank = v-bank.
       		 end.

       		 if remtrz.ptype = '5' then do:
       		 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
       		 end.

                 if remtrz.ptype = '7' then do:
                 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
                 end.
                 /* CLIRING */
                 if remtrz.cover = 1 then do:
                    t-plat.vx-obm-clr = t-plat.vx-obm-clr + remtrz.amt.
                    t-plat.vx-kol-clr = t-plat.vx-kol-clr + 1.
                 end.
                 /* GROSS */
                 if remtrz.cover = 2 then do:
                    t-plat.vx-obm-gro = t-plat.vx-obm-gro + remtrz.amt.
                    t-plat.vx-kol-gro = t-plat.vx-kol-gro + 1.
                 end.
          end.
       end.
    end.
   end.

   /*if remtrz.ptype = '7' then do:
    v-cbank = ''.
    if remtrz.sbank ne '' then do:
       find bankl where bankl.bank = remtrz.sbank no-lock no-error.
       v-cbank = bankl.cbank.
    end.
    else do:
       if remtrz.scbank ne '' then do:
       find bankl where bankl.bank = remtrz.scbank no-lock no-error.
       v-cbank = bankl.cbank.
       end.
       else next.
    end.

    if v-cbank = v-mfo then do:
       find first que where que.remtrz = remtrz.remtrz no-lock no-error.
       if avail que then do:
          if que.pid = 'F' or que.pid = 'ARC' then do:

             find t-plat where t-plat.mfo = v-mfo no-lock no-error.
             if not avail t-plat then do:
                create t-plat.
			    assign t-plat.mfo  = v-mfo
       			       t-plat.bank = v-bank.
       		 end.

       		 if remtrz.source begins 'DIR' then do:
                  t-plat.vx-obm-pko = t-plat.vx-obm-pko + remtrz.amt.
                  t-plat.vx-kol-pko = t-plat.vx-kol-pko + 1.
       		 end.
       		 else do: */
             /* CLIRING */
             /*if remtrz.cover = 1 then do:
                  t-plat.vx-obm-clr = t-plat.vx-obm-clr + remtrz.amt.
                  t-plat.vx-kol-clr = t-plat.vx-kol-clr + 1.
             end.*/
             /* GROSS */
             /*if remtrz.cover = 2 then do:
                  t-plat.vx-obm-gro = t-plat.vx-obm-gro + remtrz.amt.
                  t-plat.vx-kol-gro = t-plat.vx-kol-gro + 1.
             end.
             end.
          end.
       end.
    end.
   end.*/

end.
end.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
if available ofc then usrnm = ofc.name. else usrnm = "UNKNOWN".

def var gk-sum as int init 0.
def var go-sum as deci init 0.
def var gkk-sum as int init 0.
def var goo-sum as deci init 0.

/* вывод отчета в HTML */
def stream vcrpt.
output stream vcrpt to vcreestr.htm.

{html-title.i
 &stream = " stream vcrpt "
 &title = "Отчет по входящим и исходящим платежам в тенге"
 &size-add = "xx-"
}

def var uf as char.
if v-prz = '9' then uf = "по Физическим Лицам".
else do:
    uf = "по Юридическим Лицам".
end.

put stream vcrpt unformatted
    "<BR><b>Исполнитель:</b> " usrnm format "x(35)" "<BR>" skip
    "<b>Дата:</b> " today " " string(time,"HH:MM:SS") "<BR><BR>" skip
   "<B>Отчет по входящим и исходящим платежам в тенге <br>" + uf + "<br> за период с " + string(v-dtb, "99/99/9999") + " по " + string(v-dte, "99/99/9999") + " </B><BR><BR>" skip.

put stream vcrpt unformatted
"<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

/* 1 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD rowspan = ""2""><FONT size=""1""><B>ОБОРОТЫ ПО БАНКАМ</B></FONT></TD>" skip.
for each t-plat use-index id :
    colcount = colcount + 1.
    put stream vcrpt unformatted
       "<TD colspan = ""2""><FONT size=""1""><B>" + t-plat.bank + "</B></FONT></TD>" skip.
end.
put stream vcrpt unformatted
   "</TR>" skip.

/* 2 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip.
do i = 1 to colcount - 1:
   put stream vcrpt unformatted
   "<TD><FONT size=""1"">Кол-во</FONT></TD>" skip
   "<TD><FONT size=""1"">Объем</FONT></TD>" skip.
end.
put stream vcrpt unformatted
   "</TR>" skip.


/* 3 - я строка */
put stream vcrpt unformatted
   "<TR align=""left"" >" skip
     "<TD colspan="" " string(colcount) " ""><FONT size=""1""><B>ИСХОДЯЩИЕ</B></FONT></TD>" skip  /* colspan=" string(colcount) "*/
   "</TR>" skip.

if path = '*' or path = 'G' then do:
/* 4 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>ГРОСС</B></FONT></TD>" skip.

for each t-plat where t-plat.intpay = false use-index id :
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(t-plat.isx-kol-gro) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(t-plat.isx-obm-gro) + "</FONT></TD>" skip.
       gk-sum = gk-sum + t-plat.isx-kol-gro.
       go-sum = go-sum + t-plat.isx-obm-gro.
end.

put stream vcrpt unformatted
   "</TR>" skip.
end.

if path = '*' or path = 'C' then do:
/* 5 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>КЛИРИНГ</B></FONT></TD>" skip.
for each t-plat where t-plat.intpay = false use-index id :
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(t-plat.isx-kol-clr) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(t-plat.isx-obm-clr) + "</FONT></TD>" skip.
       gk-sum = gk-sum + t-plat.isx-kol-clr.
       go-sum = go-sum + t-plat.isx-obm-clr.
end.
put stream vcrpt unformatted
   "</TR>" skip.
end.

if path = '*' or path = 'P' then do:
/* 6 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>ПРЯМЫЕ КОРРЕСПОНДЕНТСКИЕ ОТНОШЕНИЯ</B></FONT></TD>" skip.
for each t-plat where t-plat.intpay = false use-index id :
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(t-plat.isx-kol-pko) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(t-plat.isx-obm-pko) + "</FONT></TD>" skip.
       gk-sum = gk-sum + t-plat.isx-kol-pko.
       go-sum = go-sum + t-plat.isx-obm-pko.
end.
put stream vcrpt unformatted
   "</TR>" skip.
end.

put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>Итого исходящих</B></FONT></TD>" skip.
for each t-plat :
    gkk-sum = gkk-sum + t-plat.isx-kol-gro + t-plat.isx-kol-clr + t-plat.isx-kol-pko.
    goo-sum = goo-sum + t-plat.isx-obm-gro + t-plat.isx-obm-clr + t-plat.isx-obm-pko.
end.
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(gkk-sum) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(replace(replace(string(goo-sum, ">>>,>>>,>>>,>>9.99"),","," "),".",",")) + "</FONT></TD>" skip.
    gkk-sum = 0.
    goo-sum = 0.
put stream vcrpt unformatted
   "</TR>" skip.

/* 7 - я строка */
put stream vcrpt unformatted
   "<TR align=""left"" >" skip
     "<TD colspan="" " string(colcount) " ""><FONT size=""1""><B>ВХОДЯЩИЕ</B></FONT></TD>" skip /*colspan=" string(colcount) "*/
   "</TR>" skip.

if path ne 'P' then do:
/* 8 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"">" skip
     "<TD><FONT size=""1""><B>КЛИРИНГ + ГРОСС</B></FONT></TD>" skip.
for each t-plat where t-plat.intpay = false use-index id :
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">"  string(t-plat.vx-kol-clr + t-plat.vx-kol-gro) "</FONT></TD>" skip
       "<TD><FONT size=""1"">"  string(t-plat.vx-obm-clr + t-plat.vx-obm-gro) "</FONT></TD>" skip.
       gk-sum = gk-sum + t-plat.vx-kol-clr + t-plat.vx-kol-gro.
       go-sum = go-sum + t-plat.vx-obm-clr + t-plat.vx-obm-gro.
end.
put stream vcrpt unformatted
   "</TR>" skip.
end.

if path = '*' or path = 'P' then do:
/* 9 - я строка */
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>ПРЯМЫЕ КОРРЕСПОНДЕНТСКИЕ ОТНОШЕНИЯ</B></FONT></TD>" skip.
for each t-plat where t-plat.intpay = false use-index id :
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(t-plat.vx-kol-pko) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(t-plat.vx-obm-pko) + "</FONT></TD>" skip.
       gk-sum = gk-sum + t-plat.vx-kol-pko.
       go-sum = go-sum + t-plat.vx-obm-pko.
end.
put stream vcrpt unformatted
   "</TR>" skip.
end.
/*итого*/
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>Итого входящих</B></FONT></TD>" skip.
for each t-plat :
    gkk-sum = gkk-sum + t-plat.vx-kol-clr + t-plat.vx-kol-gro + t-plat.vx-kol-pko.
    goo-sum = goo-sum + t-plat.vx-obm-clr + t-plat.vx-obm-gro + t-plat.vx-obm-pko.
end.
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(gkk-sum) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(replace(replace(string(goo-sum, ">>>,>>>,>>>,>>9.99"),","," "),".",",")) + "</FONT></TD>" skip.
    gkk-sum = 0.
    goo-sum = 0.
put stream vcrpt unformatted
   "</TR>" skip.

/*«Собственные операции банка»*/
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>Собственные операции банка</B></FONT></TD>" skip.
for each t-plat where t-plat.intpay use-index id :
       gkk-sum = gkk-sum + t-plat.intpay-kol.
       goo-sum = goo-sum + t-plat.intpay-obm.
end.
      put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(gkk-sum) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(replace(replace(string(goo-sum, ">>>,>>>,>>>,>>9.99"),","," "),".",",")) + "</FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

/*всего*/
put stream vcrpt unformatted
   "<TR align=""center"" >" skip
     "<TD><FONT size=""1""><B>Всего</B></FONT></TD>" skip.
    put stream vcrpt unformatted
       "<TD><FONT size=""1"">" + string(gk-sum) + "</FONT></TD>" skip
       "<TD><FONT size=""1"">" + string(replace(replace(string(go-sum, ">>>,>>>,>>>,>>9.99"),","," "),".",",")) + "</FONT></TD>" skip.
put stream vcrpt unformatted
   "</TR>" skip.

/* конец */
put stream vcrpt unformatted
"</TABLE>" skip.

{html-end.i "stream vcrpt" }

output stream vcrpt close.

hide message no-pause.

unix silent cptwin vcreestr.htm excel.

pause 0.


