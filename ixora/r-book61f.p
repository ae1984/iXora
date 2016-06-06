/* r-book61f.p
 * MODULE
        Выписки по счетам клиентам
 * DESCRIPTION
        Книга регистрации счетов 
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
          11.06.2010 marinav
 * CHANGES
*/


def shared stream m-out.

def shared var dat1 as date.
def shared var dat2 as date.

def temp-table temp
    field  gl     like txb.gl.gl
    field  name   like txb.gl.des
    field  aaa    like txb.aaa.aaa
    field  cif    like txb.cif.cif
    field  name1  like txb.cif.name
    field  crc    like txb.crc.crc
    field  dgl    like txb.gl.whn
    field  d1     like txb.aaa.regdt
    field  d2     like txb.aaa.expdt
    field  prim   like txb.codfr.name[1].

def buffer btemp for temp.

display "   Ждите...   "  with row 5 frame ww centered .

for each txb.gl where txb.gl.subled ne "ast"  no-lock break by txb.gl.gl .

    if txb.gl.subled = "cif" then do.
       for each txb.aaa where txb.aaa.gl = txb.gl.gl no-lock.
         find txb.cif where txb.cif.cif = txb.aaa.cif no-lock no-error.
         if avail txb.cif then do.
            create temp.
            temp.gl = txb.gl.gl.
            temp.aaa = txb.aaa.aaa.
            temp.name = txb.gl.des.
            temp.cif = txb.cif.cif.
            temp.name1 = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
            temp.dgl = txb.gl.whn.
            temp.crc = txb.aaa.crc.
            temp.d1 = txb.aaa.regdt.
            temp.d2 = txb.aaa.cltdt.
            if txb.aaa.sta eq "C" then 
               run pr_zakr(txb.aaa.aaa, "cif", output temp.d2, output temp.prim). 
         end.
       end.
    end.
    if txb.gl.subled = "arp" then do.
       for each txb.arp where txb.arp.gl = txb.gl.gl no-lock.
           create temp.
           temp.gl = txb.gl.gl.
           temp.name = txb.gl.des.
           temp.aaa = txb.arp.arp.
           temp.name1 = txb.arp.des.
           temp.crc = txb.arp.crc.
           temp.d1 = txb.arp.rdt.
           temp.dgl = txb.gl.whn.
           run pr_zakr(txb.arp.arp, "arp", output temp.d2, output temp.prim).
       end.
    end.
    if txb.gl.subled = "eps" then do.
       for each txb.eps where txb.eps.gl = txb.gl.gl no-lock.
           create temp.
           temp.gl = txb.gl.gl.
           temp.name = txb.gl.des.
           temp.aaa = txb.eps.eps.
           temp.name1 = txb.eps.des.
           temp.crc = txb.eps.crc.
           temp.d1 = txb.eps.rdt.
           temp.dgl = txb.gl.whn.
           run pr_zakr(txb.eps.eps, "eps", output temp.d2, output temp.prim).
       end.
    end.
    if txb.gl.subled = "fun" then do.
       for each txb.fun where txb.fun.gl = txb.gl.gl no-lock.
           find txb.bankl where txb.bankl.bank = txb.fun.bank no-lock no-error.
           if avail bankl then do.
           create temp.
           temp.gl = txb.gl.gl.
           temp.name = txb.gl.des.
           temp.aaa = txb.fun.fun.
           temp.name1 = txb.bankl.name.
           temp.crc = txb.fun.crc.
           temp.d1 = txb.fun.duedt.
           temp.dgl = txb.gl.whn.
           run pr_zakr(txb.fun.fun, "fun", output temp.d2, output temp.prim).
           end.
        end.
    end.
    if txb.gl.subled = "dfb" then do.
       for each txb.dfb where txb.dfb.gl = txb.gl.gl no-lock.
           create temp.
           temp.gl = txb.gl.gl.
           temp.name = txb.gl.des.
           temp.aaa = txb.dfb.dfb.
           temp.name1 = txb.dfb.name.
           temp.crc = txb.dfb.crc.
           temp.d1 = txb.dfb.rdt.
           temp.dgl = txb.gl.whn.
           run pr_zakr(txb.dfb.dfb, "dfb", output temp.d2, output temp.prim).
        end.           
    end.
    if txb.gl.subled = "lon" then do.
       for each txb.lon where txb.lon.gl = txb.gl.gl no-lock.
           find txb.cif where txb.cif.cif = txb.lon.cif no-lock no-error.
           if avail txb.cif then do.
           create temp.
           temp.gl = txb.gl.gl.
           temp.name = txb.gl.des.
           temp.aaa = txb.lon.lon.
           temp.cif = txb.cif.cif.
           temp.name1 = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).
           temp.crc = txb.lon.crc.
           temp.d1 = txb.lon.opndt.
           temp.dgl = txb.gl.whn.
           run pr_zakr(txb.lon.lon, "lon", output temp.d2, output temp.prim).
           end.
       end.
    end.
    if txb.gl.subled = "" then do.
            create temp.
            temp.gl = txb.gl.gl.
            temp.dgl = txb.gl.whn.
            temp.aaa = "###".
    end.   
end.


find first txb.cmp no-lock no-error.
put stream m-out unformatted
  "<P style=""font:bold;font-size:x-small"">"  txb.cmp.name  "</P>" 
  "<P align=""left"" style=""font:bold;font-size:x-small"">КНИГА РЕГИСТРАЦИИ СЧЕТОВ (ФОРМА 61) ЗА " dat2 "</P>" skip
  "<TABLE cellspacing=""0"" cellpadding=""2"" align=""center"" border=""1"" width=""100%"">" skip.

put stream m-out unformatted
      "<TR align=""center"" style=""font:bold"">" skip
        "<TD>Счет</TD>" skip
        "<TD>Наименование </TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Дата открытия</TD>" skip
        "<TD>Дата <br>закрытия </TD>" skip
        "<TD>Примечание</TD>" skip
        "</TR>" skip.


for each temp break by temp.gl by temp.aaa by temp.crc.
    if first-of(temp.gl) then
       if (temp.dgl <= dat2  and (dat1 = ? or temp.dgl >= dat1)) or  can-find(first btemp where btemp.aaa <> "###" and 
                      btemp.gl = temp.gl and  btemp.d1 <= dat2 and (dat1 = ? or btemp.d1 >= dat1))
       then do:
        put stream m-out unformatted
                     "<TR style=""font:bold"">" skip
               	       "<TD> Счет ГК " temp.gl "</TD>" skip
                       "<TD>" temp.name "</TD>" skip
                       "<TD> Открыт</TD>" skip
                       "<TD>" temp.dgl "</TD><TD></TD>" skip
                       "<TD></TD>" skip
                     "</TR>" skip.
 
    end.
    if temp.aaa <>"###" then do:
       find first txb.crc where txb.crc.crc = temp.crc no-lock no-error.
       if d1 le dat2 and (dat1 = ? or d1 ge dat1) then do:
        put stream m-out unformatted
                     "<TR>" skip
               	       "<TD>" temp.aaa "</TD>" skip
                       "<TD>" temp.name1 "</TD>" skip
                       "<TD>" txb.crc.code "</TD>" skip
                       "<TD>" temp.d1 "</TD>" skip.

          if temp.d2 le dat2 and (dat1 = ? or temp.d2 ge dat1) 
             then put stream m-out unformatted "<TD>" temp.d2 "</TD>" skip.
             else put stream m-out unformatted "<TD></TD>" skip.
                  if temp.d2 le dat2 and (dat1 = ? or temp.d2 ge dat1) 
                     then put stream m-out unformatted "<TD>" temp.prim "</TD></TR>"  skip.
                     else put stream m-out unformatted "<TD></TD></TR>" skip.
       end.                
    end. /* ne ### */
end.       


put stream m-out unformatted "</table><br><br>" skip.


/* */
procedure pr_zakr.
 def input parameter ch like txb.aaa.aaa.
 def input parameter subl like txb.gl.subled.
 def output parameter dt like txb.aaa.cltdt.
 def output parameter pr like txb.codfr.name[1].

 find txb.sub-cod where txb.sub-cod.acc = ch
                and txb.sub-cod.sub         = subl
                and txb.sub-cod.d-cod       = "clsa"
                and txb.sub-cod.ccode       ne "msc"
                no-lock no-error.
      if avail txb.sub-cod then do.
         dt = txb.sub-cod.rdt.
         find txb.codfr where txb.codfr.codfr = txb.sub-cod.d-cod
                         and  txb.codfr.code  = txb.sub-cod.ccode no-lock no-error.
         if avail txb.codfr then pr = txb.codfr.name[1].
      end.

end procedure.               
