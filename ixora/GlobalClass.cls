/* GlobalClass.cls

 * MODULE
        
 * DESCRIPTION
        
 * RUN
        Способ вызова программы, описание параметров, примеры вызова 
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список функций класса
                  
 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK       
 * AUTHOR
        24.02.2009 k.gitalov
 * CHANGES
        
*/


/* Базовый класс для инициализации объектов содержащий глобальные переменные*/


CLASS GlobalClass:
  
  DEFINE  PUBLIC PROPERTY g-lang   AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-crc    AS INT   GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-ofc    AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-proc   AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-fname  AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-today  as date  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-comp   AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-dbdir  AS CHAR  GET . PRIVATE  SET . /* Database Directory */
  DEFINE  PUBLIC PROPERTY g-dbname AS CHAR  GET . PRIVATE  SET . /* Database Name */
  DEFINE  PUBLIC PROPERTY g-cdlib  AS LOG   GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-browse AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-editor AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-pfdir  AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-permit AS INT   GET . PRIVATE  SET .

  DEFINE  PUBLIC PROPERTY g-lprpt  AS CHAR  GET . PRIVATE  SET . /* LP command for rpt */
  DEFINE  PUBLIC PROPERTY g-lplab  AS CHAR  GET . PRIVATE  SET . /* LP command for label */
  DEFINE  PUBLIC PROPERTY g-lplet  AS CHAR  GET . PRIVATE  SET . /* LP command for letter */
  DEFINE  PUBLIC PROPERTY g-lpstmt AS CHAR  GET . PRIVATE  SET . /* LP command for statement */
  DEFINE  PUBLIC PROPERTY g-lpvou  AS CHAR  GET . PRIVATE  SET . /* LP command for voucher */

  DEFINE  PUBLIC PROPERTY g-labfmk AS CHAR  GET . PRIVATE  SET . /* Form Lable Program */
  DEFINE  PUBLIC PROPERTY g-stmtmk AS CHAR  GET . PRIVATE  SET . /* Form Statement Program */
  DEFINE  PUBLIC PROPERTY g-letfmk AS CHAR  GET . PRIVATE  SET . /* Form Letter Program */

  DEFINE  PUBLIC PROPERTY g-bra    AS INT   GET . PRIVATE  SET .

  DEFINE  PUBLIC PROPERTY g-basedy AS INT   GET . PRIVATE  SET .

  DEFINE  PUBLIC PROPERTY g-tty    AS INT   GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-lty    AS INT   GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-aaa    AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-cif    AS CHAR  GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-batch  AS LOG   GET . PRIVATE  SET .
  DEFINE  PUBLIC PROPERTY g-defdfb AS CHAR  GET . PRIVATE  SET . /* Default DFB */
  DEFINE  PUBLIC PROPERTY g-inc    AS INT   GET . PRIVATE  SET .

  DEFINE  PUBLIC PROPERTY b-txb    AS CHAR  GET . PRIVATE  SET . /*Код филиала банка*/
  DEFINE  PUBLIC PROPERTY b-addr   AS CHAR  GET . PRIVATE  SET . /*Адрес филиала*/
  DEFINE  PUBLIC PROPERTY dep-id   AS INT   GET . PRIVATE  SET . /*ID департамента офицера*/
  DEFINE  PUBLIC PROPERTY ofcname  AS CHAR  GET . PRIVATE  SET . /*Ф.И.О офицера*/
  /*****************************************************************/
  CONSTRUCTOR  public GlobalClass(INPUT  lang   AS CHAR  ,
                                  INPUT  crc    AS INT   ,
                                  INPUT  ofc    AS CHAR  ,
                                  INPUT  proc   AS CHAR  ,
                                  INPUT  fname  AS CHAR  ,
                                  INPUT  operday  as date  ,
                                  INPUT  comp   AS CHAR  ,
                                  INPUT  dbdir  AS CHAR  , 
                                  INPUT  dbnames AS CHAR  , 
                                  INPUT  cdlib  AS LOG   ,
                                  INPUT  browses AS CHAR  ,
                                  INPUT  editors AS CHAR  ,
                                  INPUT  pfdir  AS CHAR  ,
                                  INPUT  permit AS INT   ,
                                  INPUT  lprpt  AS CHAR  , 
                                  INPUT  lplab  AS CHAR  , 
                                  INPUT  lplet  AS CHAR  , 
                                  INPUT  lpstmt AS CHAR  , 
                                  INPUT  lpvou  AS CHAR  ,
                                  INPUT  labfmk AS CHAR  ,
                                  INPUT  stmtmk AS CHAR  ,
                                  INPUT  letfmk AS CHAR  , 
                                  INPUT  bra    AS INT   ,
                                  INPUT  basedy AS INT   ,
                                  INPUT  tty    AS INT   ,
                                  INPUT  lty    AS INT   ,
                                  INPUT  aaa    AS CHAR  ,
                                  INPUT  cif    AS CHAR  ,
                                  INPUT  batch  AS LOG   ,
                                  INPUT  defdfb AS CHAR  , 
                                  INPUT  inc    AS INT ):
    g-lang    =  lang.
    g-crc     =  crc.
    g-ofc     =  ofc.
    g-proc    =  proc.
    g-fname   =  fname.
    g-today   =  operday.
    g-comp    =  comp.
    g-dbdir   =  dbdir.
    g-dbname  =  dbnames.
    g-cdlib   =  cdlib.
    g-browse  =  browses.
    g-editor  =  editors.
    g-pfdir   =  pfdir.
    g-permit  =  permit.
    g-lprpt   =  lprpt.
    g-lplab   =  lplab.
    g-lplet   =  lplet.
    g-lpstmt  =  lpstmt.
    g-lpvou   =  lpvou.
    g-labfmk  =  labfmk.
    g-stmtmk  =  stmtmk.
    g-letfmk  =  letfmk.
    g-bra     =  bra.
    g-basedy  =  basedy.
    g-tty     =  tty.
    g-lty     =  lty.
    g-aaa     =  aaa.
    g-cif     =  cif.
    g-batch   =  batch.
    g-defdfb  =  defdfb.
    g-inc     =  inc.
     
    
    find sysc where sysc.sysc = 'OURBNK' no-lock no-error.
    if avail sysc then do:
     b-txb = sysc.chval.
    end.
    else do: message "Отсутствует переменная OURBNK!" view-as alert-box. end.
         
    dep-id =   GetDep(g-ofc, g-today).
    find first depaccnt where depaccnt.depart = dep-id no-lock no-error.
    if avail depaccnt and depaccnt.rem <> '' then
    do:
      find first cmp no-lock no-error.
      find first ppoint where ppoint.depart = depaccnt.depart no-lock no-error.
      if avail ppoint then
      do:
       /* b-name = cmp.name.*/
        b-addr = trim(ppoint.name).
      end.
    end.
    
    
    find first ofc where ofc.ofc = g-ofc no-lock no-error.
    if avail ofc then ofcname = ofc.name.
    else ofcname = g-ofc.   
       
  END CONSTRUCTOR.
  /*****************************************************************/
  DESTRUCTOR  public GlobalClass():
    /* message "CLASS GlobalClass DESTROY..." view-as alert-box.*/
  end DESTRUCTOR.
  /*****************************************************************/
  method public int GetDep(usr as char, dat as date):
    
	def var v-dep like ofchis.depart no-undo.
	find last ofchis where ofc = usr and regdt <= dat use-index ofchis no-lock no-error.
	if not avail ofchis then
	do:
		find first ofchis where ofc = usr and regdt >= dat use-index ofchis no-lock no-error.
		if not avail ofchis then	    
			v-dep = 1. /*Если истории по пользователю не оказалось, то говорим, что он работает в Центральном офисе*/
		else
			v-dep = ofchis.depart.
	end.
	else
		v-dep = ofchis.depart.
	return v-dep.
   
  end method. 
  /*****************************************************************/
END CLASS.