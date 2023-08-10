Const FINAL_PATH = "C:\AutoStore\AdvancedTraining_Mar2013\Test Output\"

Const DSN = "data source=AdvancedTraining" 

' IN:
' p_MedicalRecord
' p_DocumentType
' p_ClinicNumber
' p_DocLabelSequence
' p_ScannerLocation
' p_MFPSerialNumber

' OUT:
'~USR::%FINAL_PATH%~ = 
	' Store the tagged index files In the following location:
	' FINAL_PATH\Index File
	' The TIFF images are stored into the following location:
	' FINAL_PATH\Image\

'~USR::%FINAL_FILENAME%~ = <SCANNER_LOCATION>_<DOCTYPE>_<MFP_SERIAL_NUMBER>_<TIMESTAMP>

'~USR::%FINAL_METADATA%~
'  FINAL_PATH\Image\1234_ADMAGREE_7907GD0_1305137487608.tif
	' MEDICAL RECORD: 123456
	' DOCUMENT TYPE: ADMAGREE
	' PATIENT LAST NAME: DONOVAN
	' CLINIC NUMBER: 1234
	' SCANNER LOCATION: 1234
	' DOC LABEL SEQUENCE: 001


Sub rFinalWorkflow_OnLoad
	EKOManager.StatusMessage ("p_MedicalRecord = " & p_MedicalRecord)
	EKOManager.StatusMessage ("p_DocumentType = " & p_DocumentType)
	EKOManager.StatusMessage ("p_ClinicNumber = " & p_ClinicNumber)
	EKOManager.StatusMessage ("p_ScannerLocation = " & p_ScannerLocation)
	EKOManager.StatusMessage ("p_DocLabelSequence = " & p_DocLabelSequence)
	
	Call GetPatientByMRN(p_MedicalRecord, p_PatientLastName, donotUse)
	EKOManager.StatusMessage ("..PatientLastName = " & p_PatientLastName)
	
	Set KDocument = KnowledgeObject.GetFirstDocument       
	If Not(KDocument Is Nothing) Then		
		Set PTopic = KnowledgeObject.GetPersistenceTopic()
		Set Topic  = KnowledgeContent.GetTopicInterface
        
		If Not(Topic Is Nothing) Then
			Dim timeStamp : timeStamp = GetDateTimeStamp()
			
			Dim filename : filename = p_ClinicNumber & "_" & p_DocumentType & "_" & p_MFPSerialNumber & "_" & timeStamp
			Dim metadata : metadata = ""
			metadata = metadata & FINAL_PATH & "\Image\" & filename & ".tif" & vbcrlf
			metadata = metadata & "MEDICAL RECORD: " & p_MedicalRecord & vbcrlf
			metadata = metadata & "DOCUMENT TYPE: " & p_DocumentType & vbcrlf
			metadata = metadata & "PATIENT LAST NAME: " & p_PatientLastName & vbcrlf
			metadata = metadata & "CLINIC NUMBER: " & p_ClinicNumber & vbcrlf
			metadata = metadata & "SCANNER LOCATION: " & p_ClinicNumber & vbcrlf
			metadata = metadata & "DOC LABEL SEQUENCE: " & p_DocLabelSequence & vbcrlf
			
			Topic.Replace "~USR::%FINAL_PATH%~", FINAL_PATH			
			Topic.Replace "~USR::%FINAL_FILENAME%~", filename
			Topic.Replace "~USR::%FINAL_METADATA%~", metadata
			
			EKOManager.StatusMessage ("~USR::%FINAL_PATH%~ = " & FINAL_PATH)
			EKOManager.StatusMessage ("~USR::%FINAL_FILENAME%~ = " & filename)
			EKOManager.StatusMessage ("~USR::%FINAL_METADATA%~ = " & metadata)
		Else
			KnowledgeObject.Status = 2 'KO_STATUS_BAD
			EKOManager.ErrorMessage("No Topic found")
		End If		
	Else
		KnowledgeObject.Status = 2 'KO_STATUS_BAD
		EKOManager.ErrorMessage("No KDocument found")
	End If
End Sub

Sub rFinalWorkflow_OnUnload

End Sub

Function GetDateTimeStamp
	Dim timeStamp : timeStamp = Time() & Date()
	timeStamp  = Replace(timeStamp, ":", "")
	timeStamp = Replace(timeStamp, "/", "")
	timeStamp = Replace(timeStamp, " AM", "1")
	timeStamp = Replace(timeStamp, " PM", "2")
	
	GetDateTimeStamp = timeStamp
End Function

'Msgbox GetPatientByMRN("123459", lastname, clinic) 
Function GetPatientByMRN(ByVal mrn, ByRef lastName, ByRef clinic)
	Dim patientList : patientList = ""
	Dim result_mrn
	Dim result_lastName
	Dim result_firstName
	Dim result_DOB

	Dim Conn 
	Set Conn = CreateObject("ADODB.Connection")
		
	Dim CmdString : CmdString = "SELECT MRN, LastName, FirstName, DOB, Clinic"
	CmdString = CmdString & " FROM Patient "
	CmdString = CmdString & " WHERE MRN='"&mrn&"'"
	
	ConnString = DSN
	
	Conn.Open ConnString, "", ""
	Set Rs = CreateObject("ADODB.Recordset")

	Rs.Open CmdString, Conn
		
	Do While Not Rs.eof	
		result_mrn = Rs("MRN")
		result_lastName = Rs("LastName")
		lastName = result_lastName
		result_firstName = Rs("FirstName")
		result_DOB = Rs("DOB")
		clinic = Rs("Clinic")
		
		patientList = patientList & result_lastName & ", " & result_firstName & " (" & result_dob & ") - " & result_mrn
		Rs.MoveNext
	Loop
				
	Rs.Close
	Set Rs = Nothing

	Conn.Close
	Set Conn = Nothing  
	
	GetPatientByMRN = patientList
End Function
