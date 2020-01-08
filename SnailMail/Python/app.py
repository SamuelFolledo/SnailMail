from metaphone import doublemetaphone
import re   
from unidecode import unidecode
import os

def insertName(name:str = "Mr. Sámuel Falledo"):

    #lowercase
    # doens't seem to be needed
    name = name.lower()

    #remove accented letters
    name = unidecode(name)

    #remove honorifics?
    # this will work, but it removes everything before a period, not strictly honorifics
    regex = r"\w+\. *(?=\w+)|,[\s\w]*$"
    subst = ""
    name = re.sub(regex, subst, name, 0)

    #expand common english name abbreviations
    # https://en.wiktionary.org/wiki/Appendix:Abbreviations_for_English_given_names

    #sort alphabetically
    sort_name = name.split()
    sort_name.sort()
    name = ' '.join(sort_name)

    #double metaphone conversion
    nameTuple = doublemetaphone(name)

    #check various metaphone tuple matches for name in database, return uID or error  
    uID = None 
    # database lookup and return uID @AAAAAAAA

    #if uID found, send slack message.
    if uID == None:
        #throw exception
        pass
    else:
        url = "https://slack.com/api/chat.postMessage"
        token = os.getenv("SLACK_BOT_TUT_TOKEN")
        channel = uID 
        text = "You've got mail in the 851 California St lobby :love_letter:"
        buildhttp = url+"?token="+token+"&channel="+channel+"&text="+text
        #request url

    #debug show results
    print (name)
    print (nameTuple)


if __name__ == "__main__":
    insertName() 
#    { "JNJTP" = { 'name' = 'Genji Tapia', 'uID'= '@AAAAAAAA'} }
#    { "KNJTP" = { 'name' = 'Genji Tapia', 'uID'= '@AAAAAAAA'} }
#    { "SMLFLT" = { 'name' = 'Samuel Folledo', 'uID'= '@AAABAAAA'} }
#    { "SMLFT" = { 'name' = 'Samuel Folledo', 'uID'= '@AAABAAAA'} }