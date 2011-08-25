var bird = system.presences[0];
var freeze = false;
var growing = true;

function grow()
{
  if(bird.getScale() < 1)
    growing = true;
  else if(bird.getScale() > 10)
    growing = false;
    
  if(growing)
    bird.setScale(bird.getScale() + 0.01);
  else
    bird.setScale(bird.getScale() - 0.01);
  
  if(!freeze)
    system.timeout(0.05, grow);
}
