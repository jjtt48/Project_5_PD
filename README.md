# Project_5_PD

## Team Members
- Juan Jose Toro
- Antonio Varona


## Description
This project uses Processing and Pure Data (PD) to sonify a dataset on climate change data. The goal is to provide an interactive experience where data is both visualized and sonified. As the data is read and displayed through Processing, it generates corresponding sounds using PD, allowing users to perceive data changes both visually and audibly. Users can interact with the visual representation, which, in turn, modifies the auditory experience, creating a unique integration between visuals and sound.

## How It Was Made
1. **Data Selection and Preparation**:
   - We selected a publicly available dataset on climate change to emphasize environmental issues through data sonification.
   - The data was cleaned and pre-processed to ensure that it could be easily parsed in Processing and used for both visual and auditory representations.

2. **Visualization with Processing**:
   - In Processing, we created a visual representation of the climate data. The display is dynamic, updating as the data changes to reflect different metrics in the dataset.
   - We used the oscP5 library in Processing to send OSC (Open Sound Control) messages to Pure Data, allowing real-time updates between visuals and sound.

3. **Sonification with Pure Data**:
   - Pure Data Extended, which includes the **mrpeach library**, was used to facilitate OSC message reception and sound generation.
   - As each data point is read in Processing, a corresponding sound event is triggered in PD, which varies depending on the data’s values. The sound mappings were carefully chosen to represent different aspects of the climate data, enhancing the auditory experience.
  
## Justification
We chose to use Pure Data Extended as it includes the mrpeach library, which simplifies the handling of data communications between Processing and PD. This version of Pure Data allows more flexibility when working with OSC (Open Sound Control) messages, essential for achieving a smooth integration in our sonification process.

The climate change dataset provides meaningful data to represent with sound, enabling us to convey the impact and variability of climate patterns. This choice aligns with the project's aim to use a public dataset to create dynamic and educational visual and auditory experiences.


## Requirements
- **Processing**
- **oscP5 Library for Processing** (for OSC communication)
- **Pure Data Extended** (with mrpeach library enabled)

