### - PaloAlto_FW_RunningConfigXML (ConfigSource)

> Retrieves the running config via XML for the FW in context. This differs from the LM repo (version 1.4) module because they do an IF to catch errors on both variations of API, however, the script raises an exception if there's an error on the 1st try. Meaning it will abort & never reach the 2nd try. Instead, we're using the try{}catch{} syntax, which test both tries (in case of failure on the 1st).
