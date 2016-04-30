//! Generic runtime Objects
//!
//! The Object struct is used to represent an object created during runtime. It
//! can be used to wrap native values (e.g. an integer or a string), look up
//! methods, add constants, etc.

use std::sync::{Arc, RwLock};

use object_header::ObjectHeader;
use object_value::ObjectValue;

/// A mutable, reference counted Object.
pub type RcObject = Arc<RwLock<Object>>;

/// Structure for storing information about a single Object.
pub struct Object {
    /// A unique ID associated with the object.
    pub id: usize,
    pub prototype: Option<RcObject>,
    pub header: Option<Box<ObjectHeader>>,
    pub value: ObjectValue
}

impl Object {
    pub fn new(id: usize, value: ObjectValue) -> RcObject {
        let obj = Object {
            id: id,
            prototype: None,
            header: None,
            value: value,
        };

        Arc::new(RwLock::new(obj))
    }

    pub fn set_prototype(&mut self, prototype: RcObject) {
        self.prototype = Some(prototype);
    }

    pub fn prototype(&self) -> Option<RcObject> {
        self.prototype.clone()
    }

    pub fn pin(&mut self) {
        self.allocate_header();

        let header_ref = self.header.as_mut().unwrap();

        header_ref.pinned = true;
    }

    pub fn unpin(&mut self) {
        self.allocate_header();

        let header_ref = self.header.as_mut().unwrap();

        header_ref.pinned = false;
    }

    pub fn add_method(&mut self, name: String, method: RcObject) {
        self.allocate_header();

        let mut header_ref = self.header.as_mut().unwrap();

        header_ref.methods.insert(name, method);
    }

    pub fn lookup_method(&self, name: &String) -> Option<RcObject> {
        let mut retval: Option<RcObject> = None;

        let opt_header = self.header.as_ref();

        if let Some(header) = opt_header {
            // Method defined directly on the object
            if header.methods.contains_key(name) {
                retval = header.methods.get(name).cloned();
            }
        }

        // Method defined somewhere in the object hierarchy
        else if self.prototype.is_some() {
            let mut opt_parent = self.prototype.clone();

            while opt_parent.is_some() {
                let parent_ref = opt_parent.unwrap();
                let parent     = read_lock!(parent_ref);

                let opt_parent_header = parent.header.as_ref();

                if opt_parent_header.is_some() {
                    let parent_header = opt_parent_header.unwrap();

                    if parent_header.methods.contains_key(name) {
                        retval = parent_header.methods.get(name).cloned();

                        break;
                    }
                }

                opt_parent = parent.prototype.clone();
            }
        }

        retval
    }

    pub fn add_constant(&mut self, name: String, value: RcObject) {
        self.allocate_header();

        let mut header_ref = self.header.as_mut().unwrap();

        header_ref.constants.insert(name, value);
    }

    pub fn lookup_constant(&self, name: &String) -> Option<RcObject> {
        let mut retval: Option<RcObject> = None;

        let opt_header = self.header.as_ref();

        if let Some(header) = opt_header {
            if header.constants.contains_key(name) {
                retval = header.constants.get(name).cloned();
            }
        }

        // Look up the constant in one of the parents.
        else if self.prototype.is_some() {
            let mut opt_parent = self.prototype.clone();

            while opt_parent.is_some() {
                let parent_ref = opt_parent.unwrap();
                let parent     = read_lock!(parent_ref);

                let opt_parent_header = parent.header.as_ref();

                if opt_parent_header.is_some() {
                    let parent_header = opt_parent_header.unwrap();

                    if parent_header.constants.contains_key(name) {
                        retval = parent_header.constants.get(name).cloned();

                        break;
                    }
                }

                opt_parent = parent.prototype.clone();
            }
        }

        retval
    }

    pub fn add_attribute(&mut self, name: String, object: RcObject) {
        self.allocate_header();

        let header = self.header.as_mut().unwrap();

        header.attributes.insert(name, object.clone());
    }

    pub fn lookup_attribute(&self, name: &String) -> Option<RcObject> {
        let mut retval: Option<RcObject> = None;

        let opt_header = self.header.as_ref();

        if opt_header.is_none() {
            return retval;
        }

        let header = opt_header.unwrap();

        if header.attributes.contains_key(name) {
            retval = header.attributes.get(name).cloned();
        }

        retval
    }

    pub fn truthy(&self) -> bool {
        if self.header.is_some() {
            let opt_header = self.header.as_ref();

            opt_header.unwrap().truthy
        }
        // All objects except "false" evaluate to true
        else {
            true
        }
    }

    pub fn set_falsy(&mut self) {
        self.allocate_header();

        let opt_header = self.header.as_mut();

        opt_header.unwrap().set_falsy();
    }

    fn allocate_header(&mut self) {
        if self.header.is_none() {
            self.header = Some(Box::new(ObjectHeader::new()));
        }
    }
}