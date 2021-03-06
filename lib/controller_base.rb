require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params, :already_built_response

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if @already_built_response
      raise Exception.now('Already rendered')
    else 
      @res.status = 302
      @res.location = url
      @already_built_response = true
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type = "text/html")
    if @already_built_response
      raise Exception.now('Already rendered')
    else 
      @res["Content-Type"] = content_type
      @res.write(content)
      @already_built_response = true
      debugger
      @session.store_session(@res)
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    dir = File.dirname(__FILE__)
    cdir = dir.gsub(/\/lib/, "")
    path = File.join(cdir, 'views', "#{self.class}".underscore,"#{template_name}.html.erb")
    file = File.read(path)

    render_content(ERB.new(file).result(binding), 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
    @session.store_session(@res)
    @session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    
  end
end

