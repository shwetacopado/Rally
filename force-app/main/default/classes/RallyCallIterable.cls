/**
 * 
 * @author Ajay Sahu
 * @version 1.0
 */
public with sharing class RallyCallIterable implements Iterable<Object> {
    private List<Object> data;
    
    public RallyCallIterable(List<Object> data) {
        this.data = data;
    }
    
    public Iterator<Object> iterator() {
        return new RallyCallIterator(data);
    }
    
    public class RallyCallIterator implements Iterator<Object> {
        
        List<Object> usList { get; set; }
        Integer index { get; set; }
        Integer listSize;
            
            
        public RallyCallIterator(List<Object> data) {
            this.usList = data;
            
            listSize = usList.size();
            index = 0;
        }
        
        public boolean hasNext() {
            if (index >= usList.size()) {
                return false;
            } else {
                return true;
            }
            
        }
        
        public Object next() {
            if (!hasNext()) {
                return null;
            }
            Object element = usList.get(index);
            index++;
            return element;
        }
        
    }
}