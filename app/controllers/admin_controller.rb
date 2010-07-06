class AdminController < ApplicationController
  before_filter :login_required, :admin_required

  layout 'default'

  def index
    @pending_transactions = Withdrawal.find_all_by_state("pending")
    @pending_articles = Article.pending
  end

  def complete_transaction
    transaction = Transaction.find_by_id(params[:id])
    begin
      if transaction.complete
        render :json => true, :status => :ok
      else
        render :json => true, :status => :error
      end
    rescue Exception => e
      render :json => {:error => e.message}, :status => :ok
    end
  end

  def delete_transaction
    transaction = Transaction.find_by_id(params[:id])
    if transaction.destroy
      render :json => true, :status => :ok
    else
      render :json => true, :status => :error
    end
  end

  def handle_article
    article = Article.find_by_id(params[:id])
    unless article
      render :json => {:error => "Could not find article #{params[:id]}"}
      return
    end
    if params[:state] == "feature"
      article.state = "approved"
      article.frontpage = true
    elsif params[:state] == "deny"
      article.state = "denied"
    end
    if article.save
      render :json => {}
    else
      render :json => {:error => article.errors.first.message}
    end
  end
end
