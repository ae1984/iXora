/* amr_rech.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Процедура консолид. подсчета для amr_rep1
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        amr_rep1
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        6.1.5.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        10/12/03 - suchkov - Поправил ошибки
        04/03/04 - suchkov - Добавлено поле для даты открытия карточки
*/


DEFINE SHARED TEMP-TABLE ttblAm
  FIELD anum as integer format '99'
  FIELD catname   like taxcat.name
  FIELD cat       like taxcat.type format '99'
  FIELD subcat    like taxcat.cat  format '99'
  FIELD amPrec    like taxcat.pc   format '99'
  FIELD amBBal    like ast.amt[4] format 'zzz,zzz,zzz.99'
  FIELD amIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'

  FIELD amTemp      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempPrec  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempR     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempRInc  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD am100MRP     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempF     like ast.amt[4] format 'zzz,zzz,zzz.99-'
.

DEFINE SHARED TEMP-TABLE ttblAm2
  FIELD anum as integer format '99'
  FIELD catname   like taxcat.name
  FIELD cat       like taxcat.type format '99'
  FIELD subcat    like taxcat.cat  format '99'
  FIELD amPrec    like taxcat.pc   format '99'
  FIELD amBBal    like ast.amt[4] format 'zzz,zzz,zzz.99'
  FIELD amIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'

  FIELD amTemp      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempPrec  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempR     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempRInc  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD am100MRP     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD amTempF     like ast.amt[4] format 'zzz,zzz,zzz.99-'
.


DEFINE SHARED TEMP-TABLE tblFull
  FIELD fAst     like ast.ast
  FIELD fName    like ast.name
  FIELD fBAmt    like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fIn      like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fOut     like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fRepair  like ast.amt[4] format 'zzz,zzz,zzz.99-'
  FIELD fCode    as char
  FIELD fCat     like taxcat.type format '99'
  FIELD fSubCat  like taxcat.cat  format '99'
  FIELD fPrec    like taxcat.pc   format '99'
  FIELD fAmr2    as logical 
  FIELD fAcc     as char format 'x(10)' 
  FIELD fRdt     as date
  INDEX fInx     fAst fCode ASCENDING
.

DEFINE SHARED VARIABLE bDate AS DATE. 
DEFINE SHARED VARIABLE eDate AS DATE.


define var v-num as integer init 1.
define var v-num2 as integer init 1.

define var InCodes  as char init "1,10,2,20,3,30,81,p0".
define var OutCodes as char init "4,40,5,50,6,60,86".
define var RepCodes as char init "r,r1".
define var ExcAmr2  as char.

/*output to 'ast1.log' append.*/


PROCEDURE f_group:

DEFINE INPUT PARAMETER mCat AS CHAR.
DEFINE INPUT PARAMETER mSubCat AS CHAR.

find ttblAm where ttblAm.cat = INTEGER(mCat) and ttblAm.subcat = INTEGER(mSubcat) no-error.
if not avail ttblAm then
   do:
      create ttblAm.
      find taxcat where taxcat.cat = INTEGER(mSubCat) and taxcat.type = INTEGER(mCat) no-lock no-error.
      if avail taxcat then ttblAm.catname = taxcat.name.
                      else ttblAm.catname = 'Группа не найдена'.
      ttblAm.anum = v-num. 
      v-num = v-num + 1.
      ttblAm.cat    = INTEGER(mCat).
      ttblAm.subcat = INTEGER(mSubCat).
      ttblAm.amPrec = taxcat.pc / 12 * MONTH(edate). 
   end.

find ttblAm2 where ttblAm2.cat = INTEGER(mCat) and ttblAm2.subcat = INTEGER(mSubcat) no-error.
if not avail ttblAm2 then
   do:
      create ttblAm2.
      find taxcat where taxcat.cat = INTEGER(mSubCat) and taxcat.type = INTEGER(mCat) no-lock no-error.
      if avail taxcat then ttblAm2.catname = taxcat.name.
                      else ttblAm2.catname = 'Группа не найдена'.
      ttblAm2.anum = v-num. 
      v-num2 = v-num2 + 1.
      ttblAm2.cat    = INTEGER(mCat).
      ttblAm2.subcat = INTEGER(mSubCat).
      ttblAm2.amPrec = taxcat.pc / 12 * MONTH(edate) * 2. 
   end.


find txb.sysc where txb.sysc.sysc = 'Amr2' no-lock no-error.
if avail txb.sysc then ExcAmr2 = txb.sysc.chval. else ExcAmr2 = ''.

find txb.sysc where txb.sysc.sysc = 'CLECOD' no-lock no-error.
if not avail txb.sysc then message 'Не найдена переменная CLECOD!!!' view-as alert-box TITLE "Ошибка".

for each txb.ast, each txb.fagn where txb.ast.fag = txb.fagn.fag and txb.fagn.cont = mCat and txb.fagn.ref = mSubCat by txb.ast.fag:
      find tblFull where tblFull.fAst = txb.ast.ast and tblFull.fCode = txb.sysc.chval no-error.
      if not avail tblFull
         then 
           do:
              create tblFull.
              tblFull.fAst  = txb.ast.ast.
              tblFull.fRdt  = txb.ast.rdt.
              tblFull.fCode = txb.sysc.chval.
              tblFull.fName = txb.ast.name.
              tblFull.fbAmt = txb.ast.amt[4].
              tblFull.fCat  = INTEGER(mCat).
              tblFull.fSubCat = INTEGER(mSubCat).
              tblFull.fPrec = ttblAm.amPrec.
              if tblFull.fbAmt = 0 then tblFull.fAmr2 = true. else tblFull.fAmr2 = false.
              if lookup(txb.ast.ast,ExcAmr2) <> 0 
                 then tblFull.fAmr2 = false.
           end.
         else
           do: message 'Обнаружено две карточки с одинаковым номером!' view-as alert-box TITLE "Ошибка". quit. end.
/*      if tblFull.fAmr2 = false 
         then ttblAm.amBBal = ttblAm.amBBal + txb.ast.amt[4].
         else ttblAm2.amBBal = ttblAm2.amBBal + txb.ast.amt[4].*/
      for each astjln where astjln.aast = ast.ast and astjln.ajdt >= bDate and astjln.ajdt <= eDate use-index astdt no-lock /* break by aast*/ :
          tblFull.fAcc = txb.astjln.koracc.
          if lookup(astjln.atrx,InCodes) <> 0
           then 
            do:
              case astjln.adc:
                   when 'd' then
                              do: 
/*                                 if tblFull.fAmr2 = false  
                                    then ttblAm.amIn = ttblAm.amIn + astjln.d[1].
                                    else ttblAm2.amIn = ttblAm2.amIn + astjln.d[1].*/
                                 tblFull.fIn = tblFull.fIn + astjln.d[1].
                              end.
                   when 'c' then 
                              do:
/*                                 if tblFull.fAmr2 = false  
                                    then ttblAm.amIn = ttblAm.amIn - astjln.c[1].
                                    else ttblAm2.amIn = ttblAm2.amIn - astjln.c[1].*/
                                 tblFull.fIn = tblFull.fIn - astjln.c[1].
                              end.
              end case.
            end.
           else
             do:
                if lookup(astjln.atrx,OutCodes) <> 0
                   then 
                     do:
                        case astjln.adc:
                          when 'd' then 
                                     do:
/*                                        if tblFull.fAmr2 = false  
                                           then ttblAm.amOut = ttblAm.amOut - astjln.d[1].
                                           else ttblAm2.amOut = ttblAm2.amOut - astjln.d[1].*/
                                        tblFull.fOut = tblFull.fOut - astjln.d[1].
                                     end.
                          when 'c' then 
                                     do:
/*                                        if tblFull.fAmr2 = false  
                                           then ttblAm.amOut = ttblAm.amOut + astjln.c[1].
                                           else ttblAm2.amOut = ttblAm2.amOut + astjln.c[1].*/
                                        tblFull.fOut = tblFull.fOut + astjln.c[1].
                                     end.
                        end case.
                     end.
                   else
                     do:
                        if lookup(astjln.atrx,RepCodes) <> 0
                           then 
                             do:
                                case astjln.adc:
                                  when 'd' then 
                                             do:
/*                                                if tblFull.fAmr2 = false  
                                                   then ttblAm.amRepair = ttblAm.amRepair + astjln.d[1].
                                                   else ttblAm2.amRepair = ttblAm2.amRepair + astjln.d[1].*/
                                                tblFull.fRepair = tblFull.fRepair + astjln.d[1].
                                             end.
                                  when 'c' then 
                                             do:
/*                                                if tblFull.fAmr2 = false  
                                                   then ttblAm.amRepair = ttblAm.amRepair - astjln.c[1].
                                                   else ttblAm2.amRepair = ttblAm2.amRepair - astjln.c[1].*/
                                                tblFull.fRepair = tblFull.fRepair - astjln.c[1].
                                             end.
                                end case.
                             end.
                     end.
             end.
      end.  /*for each astjln*/   
end.

END PROCEDURE.

       run f_group(1,1).
       run f_group(4,3).
       run f_group(5,17).
       run f_group(7,4).
       run f_group(8,1).
       run f_group(8,2).
       run f_group(9,3).
       run f_group(9,4).
       run f_group(9,5).
       run f_group(19,1).

/*output close.*/
