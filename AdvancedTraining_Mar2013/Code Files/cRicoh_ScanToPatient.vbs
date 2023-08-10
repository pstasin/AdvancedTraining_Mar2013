Const DEFAULT_CLINIC = "1111"
Const DSN = "AdvancedTraining"
Const ROOT_PATH = "C:\AutoStore\AdvancedTraining_Mar2013"
	
Sub Form_OnLoad(Form)
	Dim formName : formName = Form.GetFieldValue("hiddenFormName")
	
	If (formName = "mrn") Then
		Call Form.UpdateLabelField("Label", 3, "Press the 'MRN' button to input the MRN #")	
		Call Form.SetFieldVisible("Clinic #", False)
	Else
		Call Form.SetFieldValue("Clinic #", DEFAULT_CLINIC)
		Call Form.SetFieldValue("Patient Last Name", "")		
	End If
	
	Call Form.SetFieldVisible("Patient Search Results", False)
	Call Form.SetFieldVisible("Form Type", False)
	Call Form.SetFieldVisible("Document Name", False)

	Call Form.UpdateListField("Patient Search Results", True, "", "")
	
	Dim listContent : listContent = GetDocumentTypes(ROOT_PATH & "\Document Types\Clinic.txt")	
	Call Form.UpdateListField("Document Name", True, listContent, "")
End Sub

Function Form_OnScan(Form)
	Dim patientResult : patientResult = Form.GetFieldValue("Patient Search Results")
	If (Len(patientResult) = 0) Then
		Form_OnScan = "No patient selected, please try again"
	End If
End Function


Sub Field_OnChanged(Form, FieldName, FieldValue)	
	Dim formName : formName = Form.GetFieldValue("hiddenFormName")
	
	If (formName = "mrn") Then
		Call Form.SetFieldVisible("Label", False)
	Else
		Dim clinicValue : clinicValue = Form.GetFieldValue("Clinic #")
		Dim lastNameValue : lastNameValue = Form.GetFieldValue("Patient Last Name")		
		Call Form.StatusMsg("clinicValue = " & clinicValue)
		Call Form.StatusMsg("lastNameValue = " & lastNameValue)
	End If

	
	Dim patientDetail : patientDetail = ""	
	
	Dim doPatientLookup : doPatientLookup = False

	If (FieldName = "Clinic #") Then
		If (Len(Form.GetFieldValue("Patient Last Name")) > 0) Then
			doPatientLookup = True
		End If		
	ElseIf (FieldName = "Patient Last Name") Then
		doPatientLookup = True
	ElseIf (FieldName = "Patient Search Results") Then
		patientDetail = GetPatientByMRN(FieldValue, clinicValue) 
		Dim kvPatient : kvPatient = Split(patientDetail, "-")
		Call Form.UpdateLabelField("Label2", 3, "Patient = " & kvPatient(0))					
		Call Form.UpdateLabelField("Label8", 3, "Press the green START button to start scanning")					
		Call Form.SetFieldVisible("Patient Search Results", True)
		Call Form.SetFieldVisible("Form Type", True)
		Call Form.SetFieldVisible("Document Name", True)
	ElseIf (FieldName = "MRN") Then
		patientDetail = GetPatientByMRN(FieldValue, clinicValue) 
		If (len(patientDetail) = 0) Then
			Call Form.UpdateLabelField("Label2", 3, "No result found")								
			Call Form.SetFieldVisible("Clinic #", False)
			Call Form.SetFieldVisible("Form Type", False)
			Call Form.SetFieldVisible("Document Name", False)
			Call Form.UpdateLabelField("Label8", 3, "")
			Call Form.UpdateListField("Patient Search Results", True, "", "")
		Else
			Dim kvPatient2 : kvPatient2 = Split(patientDetail, "-")
			Call Form.UpdateLabelField("Label2", 3, "Patient = " & kvPatient2(0))					
			Call Form.SetFieldVisible("Clinic #", True)
			Call Form.SetFieldVisible("Form Type", True)
			Call Form.SetFieldVisible("Document Name", True)
			Call Form.UpdateLabelField("Label8", 3, "Press the green START button to start scanning")
			Call Form.SetFieldValue("Clinic #", clinicValue)
			Call Form.UpdateListField("Patient Search Results", True, FieldValue, FieldValue)
		End If	
	ElseIf (FieldName = "Form Type") Then
		If (FieldValue = "Clinic") Then
			Dim listContent : listContent = GetDocumentTypes(ROOT_PATH & "\Document Types\Clinic.txt")			
			Call Form.UpdateListField("Document Name", True,listContent, "")
		Else
			Dim listContentBilling : listContentBilling = GetDocumentTypes(ROOT_PATH & "\Document Types\Billing Group.txt")			
			Call Form.UpdateListField("Document Name", True, listContentBilling, "")
		End If
	End If
	
	If doPatientLookup Then
		Dim patientSearchResult : patientSearchResult = ValidatePatient(lastNameValue, clinicValue)
		If (Len(patientSearchResult) = 0) Then
			goToNextForm = False
			Call Form.UpdateLabelField("Label2", 3, "No search results found, please try again")	
			Call Form.SetFieldVisible("Patient Search Results", False)
			Call Form.SetFieldVisible("Form Type", False)
			Call Form.SetFieldVisible("Document Name", False)
		Else ' 1 or more results
			If (Instr(patientSearchResult, ";") > 0) Then ' 1+ results
				Dim arrResults : arrResults = Split(patientSearchResult, ";")
				Call Form.UpdateLabelField("Label2", 3, (UBound(arrResults) + 1) & " results found, press 'Patient Search Results' above")									
				Call Form.UpdateListField("Patient Search Results", True, patientSearchResult, "")
				Call Form.SetFieldVisible("Patient Search Results", True)
				Call Form.SetFieldVisible("Form Type", False)
				Call Form.SetFieldVisible("Document Name", False)
			Else ' 1 result
				Dim kv : kv = Split(patientSearchResult, "=")
				Call Form.UpdateLabelField("Label2", 3, "Patient = " & kv(0))							
				Call Form.UpdateLabelField("Label8", 3, "Press the green START button to start scanning")					
				Call Form.UpdateListField("Patient Search Results", True, patientSearchResult, patientSearchResult)				
				Call Form.SetFieldVisible("Patient Search Results", False)
				Call Form.SetFieldVisible("Form Type", True)
				Call Form.SetFieldVisible("Document Name", True)
			End If
		End If
	End If
End Sub


Function Field_OnValidate(FieldName, FieldValue)

End Function

Sub Button_OnClick(Form, ButtonName)

End Sub

' ***************************
' ***** Custom Queries ******
' ***************************


' Uncomment out below to run test when admin clicks compile (ensure to re-comment out before use in production)
' msgbox ValidatePatient("SMI", 1111)
Function ValidatePatient(ByVal lastName, ByVal clinic)
	Dim patientList : patientList = ""
	Dim result_mrn
	Dim result_lastName
	Dim result_firstName
	Dim result_DOB
	
	lastName = UCASE(lastName)

	Dim Conn 
	Set Conn = CreateObject("ADODB.Connection")

	Dim CmdString : CmdString = "SELECT MRN, LastName, FirstName, DOB"
	CmdString = CmdString & " FROM Patient "
	CmdString = CmdString & " WHERE Clinic='"&clinic&"' AND LastName Like '%" & lastName & "%'"
		
	ConnString = DSN 		
	
	Conn.Open ConnString, "", ""
	Set Rs = CreateObject("ADODB.Recordset")
		
	Rs.Open CmdString, Conn
	
	Do While Not Rs.eof	
		result_mrn = Rs("MRN")
		result_lastName = Rs("LastName")
		result_firstName = Rs("FirstName")
		result_DOB = Rs("DOB")
		
		If (Len(patientList) > 0) Then
			patientList = patientList & ";"
		End If
		patientList = patientList & result_lastName & ", " & result_firstName & " (" & result_dob & ") - #" & result_mrn & "=" & result_mrn
		
		Rs.MoveNext
	Loop
				
	Rs.Close
	Set Rs = Nothing

	Conn.Close
	Set Conn = Nothing  
	
	ValidatePatient = patientList
End Function


' Uncomment out below to run test when admin clicks compile (ensure to re-comment out before use in production)
' Msgbox GetPatientByMRN("123459", clinic) 
Function GetPatientByMRN(ByVal mrn, ByRef clinic)
	Dim patientList : patientList = ""
	Dim result_mrn
	Dim result_lastName
	Dim result_firstName
	Dim result_DOB

	Dim Conn 
	Set Conn = CreateObject("ADODB.Connection")
		
	Dim CmdString : CmdString = "SELECT MRN, LastName, FirstName, DOB, '1111' As Clinic"
	CmdString = CmdString & " FROM Patient "
	CmdString = CmdString & " WHERE MRN='"&mrn&"'"
	
	ConnString = DSN 	
	
	Conn.Open ConnString, "", ""
	Set Rs = CreateObject("ADODB.Recordset")

	Rs.Open CmdString, Conn
		
	Do While Not Rs.eof	
		result_mrn = Rs("MRN")
		result_lastName = Rs("LastName")
		result_firstName = Rs("FirstName")
		result_DOB = Rs("DOB")
		clinic = Rs("Clinic")
		
		patientList = patientList & result_lastName & ", " & result_firstName & " (" & result_dob & ") #" & result_mrn & " - " & result_mrn
		Rs.MoveNext
	Loop
				
	Rs.Close
	Set Rs = Nothing

	Conn.Close
	Set Conn = Nothing  
	
	GetPatientByMRN = patientList
End Function

' Uncomment out below to run test when admin clicks compile (ensure to re-comment out before use in production)
' msgbox GetDocumentTypes("C:\AutoStore\Ricoh_DBLookup_Patient\Document Types\Clinic.txt")
Function GetDocumentTypes(path)
	Dim arrResult : arrResult = AutoStoreLibrary_ReadTextFile(path)	
	Dim listContent : listContent = ""
	For Each element In arrResult
		If (Len(listContent) > 0) Then
			listContent = listContent & ";"
		End If
		element = Replace(element,";","_")
		listContent = listContent & element
	Next

	GetDocumentTypes = listContent
End Function


Function AutoStoreLibrary_ReadTextFile(file)	
	Const ForReading = 1

	Dim arrFileLines()

	Dim ReadSuccess : ReadSuccess = False
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	If objFSO.FileExists(file) Then
		Set objFile = objFSO.OpenTextFile(file, ForReading)
		
		i = 0
		Do Until objFile.AtEndOfStream
			ReDim Preserve arrFileLines(i)
			arrFileLines(i) = objFile.ReadLine
			i = i + 1
		Loop

		objFile.Close
		ReadSuccess = True
	End If 
	
	If (Not ReadSuccess) Then
		ReDim Preserve arrFileLines(0)
		arrFileLines(0) = "Error reading settings file"	
	End If
	
	AutoStoreLibrary_ReadTextFile = arrFileLines
End Function



	
