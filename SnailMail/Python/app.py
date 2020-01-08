import os
import re #regex
import requests
from dotenv import load_dotenv #where the bot token is stored
from unidecode import unidecode #removes accented characters
from metaphone import doublemetaphone #converts a name into phonetics, allows for fuzzy name searching

def insertName(name:str = "Mr. Sámuel Falledo"):
    #lowercase
    name = name.lower() #doens't seem to be needed

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
    uID = '@UMCUQDCEN' 
    # database lookup and return uID @AAAAAAAA

    #if uID found, send slack message.
    if uID == None:
        #throw exception
        pass
    else: 
        #request url
        load_dotenv()
        token = os.getenv("BOT_USER_OAUTH_ACCESS_TOKEN")
        channel = uID
        text = "You've got mail in the 851 California St lobby :love_letter:"\
            
        pload = {'token':token,'channel':channel,'text':text}
        r = requests.post('https://slack.com/api/chat.postMessage',data = pload)
        r_dictionary= r.json()
        #possible return that message sent successfully
        print (r_dictionary['ok'])
        #print (r_dictionary) #debug the dictionary output

    #debug show results
    print (name)
    print (nameTuple)


if __name__ == "__main__":
    insertName() 
#    { "JNJTP" = { 'name' = 'Genji Tapia', 'uID'= '@AAAAAAAA'} }
#    { "KNJTP" = { 'name' = 'Genji Tapia', 'uID'= '@AAAAAAAA'} }
#    { "SMLFLT" = { 'name' = 'Samuel Folledo', 'uID'= '@AAABAAAA'} }
#    { "SMLFT" = { 'name' = 'Samuel Folledo', 'uID'= '@AAABAAAA'} }