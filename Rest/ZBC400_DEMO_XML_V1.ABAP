*&---------------------------------------------------------------------*
*& Report  ZDEMO_XML
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zdemo_xml.

DATA: gi_ixml TYPE REF TO if_ixml. "Reference for iXML object, to create XML
DATA: gi_document TYPE REF TO if_ixml_document. " Reference for XML document
DATA: gi_extension TYPE REF TO if_ixml_element. " Reference for "extension" element in document

DATA: gi_files TYPE REF TO if_ixml_element. " Reference for "files" element in document
DATA: gi_media TYPE REF TO if_ixml_element. " Reference for "media" element in document
DATA: gi_encoding TYPE REF TO  if_ixml_encoding. " Reference to set encoding

* Declarations to create output stream and render the file to application server directory

DATA: gi_stream_factory TYPE REF TO if_ixml_stream_factory,
      gi_ostream        TYPE REF TO if_ixml_ostream,
      gi_renderer       TYPE REF TO if_ixml_renderer.

DATA gv_file_path TYPE string VALUE 'c:\\Users\Public\Documents\MANIFEST.XML'.

gi_ixml = cl_ixml=>create( ). " Create object XML
gi_document = gi_ixml->create_document( ) . " Create document
gi_encoding = gi_ixml->create_encoding( byte_order = 0
                                         character_set = 'UTF-8' ).
gi_document->set_encoding( gi_encoding ).

gi_extension = gi_document->create_simple_element( name = 'extension'
                                                   parent = gi_document
                                                   ).
gi_extension->set_attribute( name = 'Type'
                            value = 'Component'
                            ).
gi_files = gi_document->create_simple_element( name = 'file'
                                               parent = gi_extension
                                               ).
gi_files->set_attribute( name = 'Folder'
                         value = 'site'
                         ).
gi_document->create_simple_element( name = 'filename'
                                    parent = gi_files
                                    value = 'index.html'
                                  ).
gi_document->create_simple_element( name = 'filename'
                                    parent = gi_files
                                    value = 'site.php'
                                   ).
gi_media = gi_document->create_simple_element( name = 'media'
                                               parent = gi_extension
                                              ).
gi_media->set_attribute( name = 'Folder'
                         value = 'media'
                        ).

gi_document->create_simple_element( name = 'folder'
                                    parent = gi_media
                                    value = 'css'
                                  ).
gi_document->create_simple_element( name = 'folder'
                                    parent = gi_media
                                    value = 'js'
                                    ).

gi_stream_factory = gi_ixml->create_stream_factory( ).
gi_ostream = gi_stream_factory->create_ostream_uri( system_id = gv_file_path ).
gi_renderer = gi_ixml->create_renderer( ostream = gi_ostream
                                        document = gi_document
                                      ).
gi_ostream->set_pretty_print( abap_true ).
gi_renderer->render( ).