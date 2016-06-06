/* cifnk.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        проверка клиента на специнструкции
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
        BANK COMM TXB
 * AUTHOR
        12/03/09 marinav
 * CHANGES
        12/03/09 marinav - проверка клиента на специнструкции
        21/10/2009 madiyar - исключение КНП по ПТП
        07/10/2011 evseev - переход на ИИН/БИН
*/

{chbin_txb.i}
def input param v-rnn as char.

def var v-bnk as char.


def shared temp-table temp
    field bank as char
    field aaa  like bank.aaa.aaa
    field crc  as char
    field cif  like bank.aaa.cif
    field name like bank.aaa.name
    field bal  as decimal
    index main is primary cif aaa.

def temp-table t-vars
  field name as char
  index main is primary name.

  create t-vars.
  t-vars.name = "K2,K-2,К2,К-2".
  create t-vars.
  t-vars.name = "ПРЕДП,АРЕСТ".




find first txb.cmp no-lock.
v-bnk = txb.cmp.name.
if v-bin then do:
   for each txb.cif where txb.cif.bin = v-rnn no-lock,  each txb.aaa of txb.cif no-lock:
      for each txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock break by txb.aas.aaa:
         if lookup(txb.aas.knp,"421,423,429") > 0 then next.
         if ((txb.aas.sta = 0) and can-find(first t-vars where index(caps(txb.aas.payee), t-vars.name) > 0)) or  txb.aas.sta <> 0  then do:

           find temp where temp.cif = txb.cif.cif and temp.aaa = txb.aaa.aaa no-lock no-error.
           if not avail temp then do:
             find txb.crc where txb.crc.crc = txb.aaa.crc.
             create temp.
             assign temp.bank = v-bnk
                    temp.aaa  = txb.aaa.aaa
                    temp.crc  = txb.crc.code
                    temp.cif  = txb.aaa.cif
                    temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

           end.
         end.
      end.
    end.
end.
else do:
    for each txb.cif where txb.cif.jss = v-rnn no-lock,  each txb.aaa of txb.cif no-lock:
      for each txb.aas where txb.aas.aaa = txb.aaa.aaa no-lock break by txb.aas.aaa:
         if lookup(txb.aas.knp,"421,423,429") > 0 then next.
         if ((txb.aas.sta = 0) and can-find(first t-vars where index(caps(txb.aas.payee), t-vars.name) > 0)) or  txb.aas.sta <> 0  then do:

           find temp where temp.cif = txb.cif.cif and temp.aaa = txb.aaa.aaa no-lock no-error.
           if not avail temp then do:
             find txb.crc where txb.crc.crc = txb.aaa.crc.
             create temp.
             assign temp.bank = v-bnk
                    temp.aaa  = txb.aaa.aaa
                    temp.crc  = txb.crc.code
                    temp.cif  = txb.aaa.cif
                    temp.name = trim(trim(txb.cif.prefix) + " " + trim(txb.cif.name)).

           end.
         end.
      end.
    end.
end.


