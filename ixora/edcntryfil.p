/* edcntry.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Переписывание измененных данных справочника стран с головной базы на филиалы
 * RUN
        
 * CALLER
        edcntry.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        9-1-2-16
 * AUTHOR
        26.08.2003 nadejda
 * CHANGES
*/


def var v-codif as char init "iso3166".

for each bank.codfr where bank.codfr.codfr = v-codif no-lock :

  find ast.codfr where ast.codfr.codfr = v-codif and ast.codfr.code = bank.codfr.code no-lock no-error.

  if not avail ast.codfr then do transaction:
    create ast.codfr.
    ast.codfr.codfr = v-codif. 
    ast.codfr.level = 1.
    ast.codfr.code = bank.codfr.code.
  end.

  if ast.codfr.name[1] <> bank.codfr.name[1] or 
     ast.codfr.name[2] <> bank.codfr.name[2] or 
     ast.codfr.tree-node <> bank.codfr.tree-node
     then do:
    find current ast.codfr exclusive-lock.

    ast.codfr.name[1] = bank.codfr.name[1].
    ast.codfr.name[2] = bank.codfr.name[2].
    ast.codfr.tree-node = bank.codfr.codfr + caps(trim(bank.codfr.name[2])) + caps(trim(bank.codfr.name[1])).
  end.
  release ast.codfr.
end.


for each ast.codfr where ast.codfr.codfr = v-codif and not can-find (bank.codfr where bank.codfr.codfr = ast.codfr.codfr and
      bank.codfr.code = ast.codfr.code no-lock) exclusive-lock:
  delete codfr.
end.

