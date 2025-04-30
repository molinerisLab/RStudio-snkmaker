# RStudio Snakemaker
This is an RStudio addin that leverage an LLM to generate snakemake workflow using either bash or R commands. 
## Installation: 
```
install.packages("devtools")

devtools::install_github("molinerisLab/RStudio-snkmaker/Snakemaker")
```
In order to launch the addin: 
Select the Addin in the RStudio menu, then select "Snakemaker"

<img width="245" alt="413875964-5ec21daf-25f3-4c46-9f51-4e72172c0db7" src="https://github.com/user-attachments/assets/41c93b2d-2456-466a-87f0-68fa6a1ee09a" />



The addin will open as a shiny app in the viewer page in the right part of the RStudio interface in a non blocking way, allowing the user to continue using the console and perform operations on it while the addin is running.


![white](https://github.com/user-attachments/assets/f5bbbf92-dc50-4226-9fe9-2b29396dcf32)

The choice of the type of history to visualize (R or bash) is done in the "Choice Menu", depending on what the user intend to visualize. 
Each history line have associated a symbol: 
★ For lines that the model classifies as Important
⭘ For lines that the model classifies as Not Important

The user can manually toggle the importance of a command by using the associated button.

When a history line is selected and the "Generate rule" is pressed, a Snakemake rule is pasted in the active document and will be stored in the archived rules section. If new commands are given both in the R console or in the terminal, by pressing "refresh history" the updated commands will be shown in the list.
The rules in the archive can be parsed again to regenerate the rule or can be discarded from the list.



## First time utilization: 
When you run the addin for the first time, a default language model will be selected, but one can change it to the available ones using the Configuration button within the addin.
Due to the lack of support of Github copilot in RStudio for other purpose other than the built in code generation, their API are not leverageable and integratable for the following addin.
This means that in order to make use of a model, it is thus necessary to own a personal API key.
When you generate your first rule, or make a first request to the model, the addin will ask to insert a API key of the corresponding selected model in order to continue. This API key will be stored in a keychain variable in your machine, and will allow the addin to work.
This API key will not be asked again, but when selecting different models that requires different API key, the prompt will ask for the new key.  

<img width="286" alt="413889321-b468de74-4dd3-4680-86fd-55185eedde48" src="https://github.com/user-attachments/assets/ce4d86f3-665e-44ef-a366-3918748f44f3" />


If the API key needs to be changed (e.g. expired API token), in the Configuration menu there is a button to delete the current saved one and the user will be asked to insert the new API key the next time a rule is generated. 



<img width="356" alt="413890835-13b5b99f-5448-415a-a0ac-d792a8f91fcf" src="https://github.com/user-attachments/assets/0c704272-5ddb-44d4-b8f7-9a881ad3f4d1" />



# Chat with LLM
This addin allows you to communicate with the language models already set up in the Snakemaker addin, to parse questions and recive response in a chat-like viewer. 

![image](https://github.com/user-attachments/assets/95855e60-6919-442f-baee-791f7ee4cae2)

By selecting the Chat with LLM a new viewer on the right side of the addin will appear. The addin run in foreground, blocking the R console but allowing to gaign some useful features: 
- Using the active document as context in order to ask for specific questions on the code/Snakemake rules present in the document
- [Expermimental] Generate an RMarkdown from the open document
  
![Untitled design](https://github.com/user-attachments/assets/3ee39c0f-7532-4b15-beb5-4f6ec0b0adf8)

The chat features  memory of the previous messages sent to the model to improve communication and gives more personalized answers. Every chat has its own history, that is specific to it. It is possible to switch between chat to go back to previous one. The chat is maintened as long as the addin is running but as for now, it deos not allow to keep record of past iterations once the addin is closed. 
