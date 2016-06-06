/* syncofc.p
 * MODULE
        Управление офицерами Прагмы
 * DESCRIPTION
        Синхронизация настройки польователя с филиалами
 * RUN
        
 * CALLER
        x-ofc.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * AUTHOR
        27.07.2006 u00121
 * CHANGES
        31.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

define shared var vofc like bank.ofc.ofc.

message "Провести синхронизацию пользователя " vofc " по всем филиалам?" view-as alert-box BUTTONS OK-CANCEL UPDATE syncall as log.
if syncall then
do:
	syncall = false.
	message "Установить пароль пользователя " vofc " по умолчанию?" view-as alert-box BUTTONS OK-CANCEL UPDATE syncall . /*если ответим нет, то необходимо будет в ручную создавать учетную запись в таблице _user */
	{r-branch.i &proc = "syncofcbr(syncall, vofc)"}                                                                                                                            
end.
else
do:
	/* 03.12.2008 id00024 - добавил выбор МКО или БАНКа */
			run sel ("It's time to choose mr. Freeman :", " 1. BAHK | 2. MKO  ").
			case return-value:
			when "1" then v-path = '/data/b'.
			when "2" then v-path = '/data/'.
			end case.

	def temp-table t-branch no-undo /*таблица для списка филиалов*/
		field path as char
		field host like comm.txb.host
		field serv like comm.txb.service
		field login as char
		field password as char
		field name as char format "x(30)"
		field txb as int
		field sel as log format "<*>/"
		index idx-txb is unique primary txb.
	find last cmp no-lock no-error.
	if not avail cmp then
	do:
		message "Не найдена Настройка банковского профайла!" skip
			"Проверьте в пункте 12-1-1-1!" skip
			"Синхронизация прекращена!" view-as alert-box.
		return.
	end.

	for each comm.txb where comm.txb.consolid = true no-lock: /*заполняем таблицу списка филиалов*/
		if comm.txb.txb <> cmp.code then
		do:
			create t-branch. 
			assign
				t-branch.path = comm.txb.path
				t-branch.host = comm.txb.host
				t-branch.serv = comm.txb.service
				t-branch.login = comm.txb.login
				t-branch.password = comm.txb.password
				t-branch.name = comm.txb.name
				t-branch.txb = comm.txb.txb.
		end.
	end.

        def query q-branch for t-branch.

	def browse b-branch 
		query q-branch no-lock
			display t-branch.name t-branch.sel with 10 down width 50 title "Список филиалов" no-labels.

	def frame f-branch
		b-branch help "Enter - выделить филиал; F1 - Продолжить" with centered no-label  row 2.

        on return of b-branch in frame f-branch /*нажатие клавиши ENTER приводит к выделению или отмене выделения филиала*/
	do:
		if avail t-branch then
		do:
			if t-branch.sel then
				t-branch.sel = false.
			else
				t-branch.sel = true.
			open query q-branch for each t-branch.
		end.
		
        end.

        open query q-branch for each t-branch.

        view frame f-branch.

        enable b-branch with frame f-branch.

        apply "VALUE-CHANGED" to BROWSE b-branch.
        WAIT-FOR "GO" OF FRAME f-branch.
	message "Установить пароль пользователя " vofc " по умолчанию?" view-as alert-box BUTTONS OK-CANCEL UPDATE syncall.
	for each t-branch where t-branch.sel no-lock. /*пробигаемся по составленному пользователем списку*/
            	if connected ("txb") then disconnect "txb".
/*                      connect value(" -db " + t-branch.path + " -H " + t-branch.host + " -S " + t-branch.serv  + " -ld txb -U " + t-branch.login + " -P " + t-branch.password).  */
                        connect value(" -db " + replace(t-branch.path,'/data/',v-path) + " -ld txb -U " + t-branch.login + " -P " + t-branch.password). /* id00024 03.12.2008 */
                run syncofcbr(syncall, vofc).
                if connected ("txb") then disconnect "txb".
	end.
end.
