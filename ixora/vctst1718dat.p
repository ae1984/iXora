/* vcrep1718dat.p
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
   08.04.2008 galina - добавлено поле cursdoc-usd в таблицу t-docs
*/

/* vcrep1718dat.p - Валютный контроль 
   Приложение 17 и 18 - все платежи за месяц по контрактам типа 2
   Сборка во временную таблицу

   19.11.2002 nadejda создан

*/

{vc.i}

def input parameter p-expimp as char.
def input parameter p-vcbank as char.
def input parameter p-depart as integer.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtb as date.
def shared var v-dte as date.

def var v-name as char.
def var v-prefix as char.
def var v-clnsts as char.
def var v-okpo as char.
def var v-partner as char.
def var v-partnprefix as char.
def var v-depart as char.
def var v-addr as char.
def var v-region as char.


def shared temp-table t-docs 
  field dndate as date
  field sum as decimal
  field payret as logical
  field docs as integer
  field paykind as char
  field cif as char
  field prefix as char
  field name as char
  field okpo as char
  field clnsts as char
  field region as char
  field addr as char
  field ctnum as char
  field ctdate as date
  field cttype as char
  field partnprefix as char
  field partner as char
  field codval as char
  field info as char
  field strsum as char
  field bank as char
  field depart as char
  field cursdoc-usd as decimal
  index main is primary cttype dndate payret sum docs.

for each vccontrs where vccontrs.bank = p-vcbank and vccontrs.cttype = "2" and
      vccontrs.expimp = p-expimp no-lock:

  find first vcdocs where vcdocs.contract = vccontrs.contract and 
      (vcdocs.dntype = "02" or vcdocs.dntype = "03") and 
      vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock no-error.  

  if avail vcdocs then do:

    find txb.cif where txb.cif.cif = vccontrs.cif no-lock no-error.
  
    if (p-depart <> 0) and (integer(txb.cif.jame) mod 1000 <> p-depart) then next.
    
    if substr(txb.cif.geo, 3, 1) = "1" then do:
      /* учитываются только резиденты - так сказала Линчевская в январе 2003 */
      v-name = trim(txb.cif.name).
      v-prefix = trim(txb.cif.prefix).

      v-addr = trim(txb.cif.addr[1]).
      if trim(txb.cif.addr[2]) <> "" then do:
        if v-addr <> "" then v-addr = v-addr + "; ".
        v-addr = v-addr + trim(txb.cif.addr[2]).
      end.
      v-addr = trim(substr(v-addr, 1, 100)).

      find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "clnsts" and txb.sub-cod.acc = txb.cif.cif 
            no-lock no-error.
      v-clnsts = if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then txb.sub-cod.ccode else "0".
      
      if v-clnsts = "1" then v-okpo = trim(txb.cif.jss).
      else do:
        find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "secek" and txb.sub-cod.acc = txb.cif.cif 
             no-lock no-error.
        if avail txb.sub-cod and txb.sub-cod.ccode = "9" then do:
          find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "ecdivis" and txb.sub-cod.acc = txb.cif.cif 
               no-lock no-error.
          if avail txb.sub-cod and txb.sub-cod.ccode = "98" then do: v-okpo = trim(txb.cif.jss).
                                                                     v-clnsts = "1".            
                                                            end.
          else v-okpo = trim(txb.cif.ssn).
        end.
        else v-okpo = trim(txb.cif.ssn).
      end.
      if decimal(v-okpo) = 0 then v-okpo = "".
      
      find txb.sub-cod where txb.sub-cod.sub = "cln" and txb.sub-cod.d-cod = "regionkz" and txb.sub-cod.acc = txb.cif.cif 
            no-lock no-error.
      if avail txb.sub-cod and txb.sub-cod.ccode <> "msc" then v-region = txb.sub-cod.ccode.
      else v-region = "75".    /* только для тестирования! ПОТОМ УДАЛИТЬ ! */

      find first txb.ppoint where txb.ppoint.point = 1 and txb.ppoint.depart = integer(cif.jame) mod 1000 no-lock no-error.
      v-depart = txb.ppoint.name.

      find vcpartner where vcpartner.partner = vccontrs.partner no-lock no-error.
      if avail vcpartner then do:
        v-partner = trim(vcpartner.name).
        v-partnprefix = trim(vcpartner.formasob).
      end.
      else do: v-partner = "". v-partnprefix = "". end.

      for each vcdocs where vcdocs.contract = vccontrs.contract and (vcdocs.dntype = "02" or vcdocs.dntype = "03") and 
              vcdocs.dndate >= v-dtb and vcdocs.dndate <= v-dte no-lock:
        find txb.ncrc where txb.ncrc.crc = vcdocs.pcrc no-lock no-error.

        create t-docs.
        assign t-docs.dndate = vcdocs.dndate
               t-docs.sum = vcdocs.sum
               t-docs.strsum = trim(string(vcdocs.sum, ">>>>>>>>9.99"))
               t-docs.payret = vcdocs.payret
               t-docs.docs = vcdocs.docs
               t-docs.paykind = "1"
               t-docs.cif = vccontrs.cif
               t-docs.name = v-name
               t-docs.prefix = v-prefix
               t-docs.okpo = v-okpo
               t-docs.clnsts = v-clnsts
               t-docs.region = v-region
               t-docs.addr = v-addr
               t-docs.partner = v-partner
               t-docs.partnprefix = v-partnprefix
               t-docs.codval = txb.ncrc.code
               t-docs.ctnum = vccontrs.ctnum
               t-docs.ctdate = vccontrs.ctdate
               t-docs.cttype = vccontrs.expimp
               t-docs.bank = vccontrs.bank
               t-docs.depart = v-depart
               t-docs.info = vcdocs.info[1].
      end.
    end.
  end.
end.

